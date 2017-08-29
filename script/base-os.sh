#!/bin/bash
#
# Install base os on clean CentOS 7
#
# Usage: curl radia.run | bash -s centos7 \
#     base-os

base_os_main() {
    if (( $EUID != 0 )); then
        install_err 'must be run as root'
    fi
    centos7_install_file etc/sysctl.d/60-rsconf-base.conf 400
    sysctl -p --system
    yum --enablerepo=extras install -y -q epel-release
    local x=(
        bind-utils
        emacs-nox
        git
        patch
        screen
        strace
        unzip
        wget
    )
    yum install -y -q "${x[@]}"
}
