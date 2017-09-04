# Assert vagrant=1000 or will nothing work?
# stdout/stderr to logs
: ${bivio_service_base_dir:=/var/lib}
: ${bivio_service_guest_user:=vagrant}
: ${bivio_service_host_dir:=$bivio_service_base_dir/$bivio_service_name}
: ${bivio_service_host_user:=$bivio_service_guest_user}
: ${bivio_service_guest_dir:=/$bivio_service_guest_user}

docker_unit_clear_vars() {
    unset $(compgen -A variable docker_unit)
}

docker_unit_main
docker_unit_start() {
    local args=$1
    service_links
    for x in ${vols[@]}; do
        if [[ ! $x =~ : ]]; then
        fi
    done
    cat > /etc/systemd/system/$rs_unit.service <<EOF
[Unit]
Description=$unit
Requires=docker.service "$requires"
After=docker.service "$requires"

[Service]
Restart=on-failure
RestartSec=10
ExecStartPre=/bin/bash -c '/usr/bin/docker rm -f $unit >& /dev/null || true'
ExecStart=/usr/bin/docker run --tty --rm --user=$rs_guest_user --host net ${volumes[@]} --name $unit --hostname c-%H $rs_image $start
ExecStop=-/usr/bin/docker stop -t 2 $unit

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable "$unit"
    systemd start "$unit"
}

# has to be global name
/var/lib/<service>/rsconf-cmd - actually executes command
/var/lib/<service>/rsconf-env - environment vars sourced by rsconf-cmd
/var/lib/<service>/rsconf-run - holds same as what is in ExecStart -- need to allow override of the container and host name so that you can run bash instead
/var/lib/<service>/rsconf-bash - holds same as what is in ExecStart -- need to allow override of the container and host name so that you can run bash instead
/var/lib/<service>/rsconf-exec - exec into container

start() {
    bivio_service_config
    bivio_service_cmd $(bivio_service_script)
    "${bivio_service_docker_cmd[@]}" > /dev/null
}

docker_unit_run_args() {
    local flag=$1
    shift
    local x
    for x in "$@"; do
        if ! [[ $flag =~ -e|--volumes-from || $x =~ : ]]; then
            x="$x:$x"
        fi
        docker_unit_run_cmd+=( $flag $x )
    done
}

docker_unit_run_cmd() {
    local cmd=(
        $bivio_service_su_wrapper
        $(id -u "$bivio_service_guest_user")
        $(id -g "$bivio_service_guest_user")
        $@
    )
    docker_unit_run_cmd+=(
        bash -c "${cmd[*]}"
    )
}

bivio_service_config() {
    bivio_service_exports=(
        "BIVIO_SERVICE_DIR=$bivio_service_guest_dir"
#TODO(robnagler) service channel necessary?
        "BIVIO_SERVICE_CHANNEL=$bivio_service_channel"
        "PYKERN_PKCONFIG_CHANNEL=$bivio_service_channel"
    )
    bivio_service_volumes=(
#TODO(robnagler) /var/lib/
        "$bivio_service_host_dir:$bivio_service_guest_dir"

    )
    bivio_service_volumes_from=()
    bivio_service_ports=()
    bivio_service_links=()
    bivio_service_hostname=$bivio_service_name

    # Docker containers inherit docker's very high ulimits
    # Python tries to close all files with a subprocess so need to lower them
    # to something more reasonable (not millions) and doesn't cause issues
    # with forks. See https://github.com/docker/docker/issues/9876
    local cmd=(
        docker
        run
        --ulimit nofile=4096:4096
        --ulimit nproc=4096:15758
        --name "$bivio_service_name"
        --tty
        --rm
        --user=${docker_unit[user]}
    )

        --net=host

    bivio_service_set_vars

    docker_unit_init() {
        clears all vars
    }

    docker_unit_add env bla=blo
    docker_unit_unset volumes

    docker_unit_env() {
        add to env var
    }

    docker_unit_env=()
    docker_unit_env_secret=()
    docker_unit_env_default()
    docker_unit_ports=()
    docker_unit_net=
    docker_unit_volumes=
    docker_unit_volumes_from=
    docker_unit_cmd=()
    docker_unit_hostname=
    docker_unit_user=
    docker_unit_links=()
    docker_unit_channel=()
    docker_unit_image=()

    bivio_service_docker_args -p "${bivio_service_ports[@]}"
    bivio_service_docker_args --link "${bivio_service_links[@]}"
    bivio_service_docker_args -v "${bivio_service_volumes[@]}"
    bivio_service_docker_args --volumes-from "${bivio_service_volumes_from[@]}"
    bivio_service_docker_args -e "${bivio_service_exports[@]}"
    bivio_service_docker_cmd+=(
        --hostname $bivio_service_hostname
        $bivio_service_image:$bivio_service_channel
    )
}

bivio_service_script() {
    local f="$bivio_service_host_dir/bivio-service"
    local v
    (
        cat <<EOF
#!/bin/bash
. ~/.bashrc
set -e
cd '$bivio_service_guest_dir'
EOF
        for v in "${bivio_service_exports[@]}"; do
            echo "export '$v'"
        done
        echo 'echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) '"${bivio_service_exec_cmd[@]}"'" >>' "$bivio_service_base_init_log"
        echo "env >> $bivio_service_base_init_log"
        if [[ $(type -t bivio_service_script_pre_exec) ]]; then
            bivio_service_script_pre_exec
        fi
        local x=''
        for v in "${bivio_service_exec_cmd[@]}"; do
            x="$x'$v' "
        done
        echo "$x>> $bivio_service_base_init_log 2>&1"
    ) > "$f"
    chmod 750 "$f"
    chgrp "$bivio_service_host_user" "$f"
    echo "$bivio_service_guest_dir/bivio-service"
}
