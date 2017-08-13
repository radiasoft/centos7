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
    local f=etc/sysctl.d/60-rs-base.conf
    install_download "$f" > "/$f"
    chmod 400 "/$f"
    sysctl -p
}
