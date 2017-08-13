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
    centos7_install_file etc/sysctl.d/60-rs-base.conf 400
    sysctl -p --system
    yum install -y -q epel-release
    yum install -y -q emacs-nox patch unzip wget git
}
