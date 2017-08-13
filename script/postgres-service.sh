#!/bin/bash
#
# Install Posgres server on clean CentOS 7
#
# Usage: curl radia.run | bash -s centos7 \
#     postgres-service

postgres_service_main() {
    if (( $EUID != 0 )); then
        install_err 'must be run as root'
    fi
    local d=/var/lib/pgsql/data
    if [[ -e $d ]]; then
        install_err "$d: already exists, uninstall postgres first"
    fi
    yum install -y postgresql-server
    cd "$d"
    postgresql-setup initdb
    local c=radiasoft.conf
    echo "include '$c'" >> postgresql.conf
    cat > pg_hba.conf <<EOF
# TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
local   all         all         127.0.0.1/32          md5
hostssl all         all         0.0.0.0/0             md5
hostssl all         all         ::/0                  md5
EOF

    chown postgres:postgres pg_hba.conf
    chmod 600 pg_hba.conf
    # server.* are default names
    openssl req -x509 -nodes -days 9999 -set_serial "$(date +%s)" \
        -newkey rsa:2048 -keyout server.key -out server.crt \
        -subj /C=US/ST=Colorado/L=Boulder/CN="$(hostname -f)"
    if [[ ! $(free -b) =~ Mem:[[:space:]]+([[:digit:]]+) ]]; then
        install_err 'free -b: format is not correct'
    fi
    # http://wiki.postgresql.org/wiki/Performance_Optimization
    # https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server
    # "If you have a system with 1GB or more of RAM, a reasonable
    # starting value for shared_buffers is 1/4 of the memory in your system."
    local sb=$(( ${BASH_REMATCH[1]} / (3 * 1024 * 1024) ))
    cat > "$c" <<EOF
checkpoint_completion_target = 0.9
checkpoint_segments = 64
effective_cache_size =  $(( $sb * 2 ))MB
listen_addresses = '*'
log_checkpoints = on
log_line_prefix = '%t %d %p '
maintenance_work_mem = 64MB
max_connections = 128
shared_buffers = ${sb}MB
ssl = on
ssl_cert_file = 'server.crt'
ssl_ciphers = 'DHE-RSA-AES256-SHA:AES256-SHA:DHE-RSA-AES128-SHA:RC4-SHA:HIGH:!ADH'
ssl_key_file = 'server.key'
wal_buffers = 64MB
work_mem = 4MB
EOF
    chown postgres:postgres "$c"
    chmod 600 "$c"
    systemctl daemon-reload
    systemctl enable postgresql
    systemctl start postgresql
}
