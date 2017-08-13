#!/bin/bash
#
# Set up home-env for root and vagrant
#

home_env_main() {
    if (( $EUID != 0 )); then
        install_err 'must be run as root'
    fi
    yum install -y git emacs-nox
    (
        set -e -o pipefail
        install_main home
        cat > /root/.post_bivio_bashrc <<EOF
export SYSTEMD_COLORS=0
# --quit-if-one-screen -quit-at-eof --quit-on-intr --no-init
export SYSTEMD_LESS=EFKX
EOF
        chmod 600 /root/.post_bivio_bashrc
    )
    if (( $? != 0 )); then
        install_err 'root environment install failed'
    fi
    # Encapsulate this
    su - vagrant <<EOF
$(declare -f $(compgen -A function install_))
$(declare -p $(compgen -A variable install_))
install_main home
EOF
}

home_env_main "${install_extra_args[@]}"
