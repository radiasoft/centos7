#!/bin/bash
#
# Create a Centos 7 VirtualBox
#
# Usage: curl radia.run | bash -s centos7 \
#     vagrant-up [guest-name:v [guest-ip:10.10.10.10]]
#

# Delete the disk below. Not easy
# VBoxManage closemedium disk <uuid> --delete

# vbguest is useful for people not wanting to use nfs
# VBoxManage list hdds|tail
# vagrant plugin install vagrant-vbguest

vagrant_up_main() {
    local host=${1:-v.bivio.biz}
    local ip=$2
    local base=${$host%%.*}
    if [[ -z $ip ]]; then
        ip=$(dig +short "$host")
        if [[ -z $ip ]]; then
            install_err "$host: host not found and IP address not supplied"
        fi
    fi
    local vdi=$base-docker.vdi
    if [[ -e Vagrantfile ]]; then
        install_err 'Vagrantfile: already exists, remove first'
    fi
    if [[ -e $vdi ]]; then
        install_err "$vdi: exists, remove first by UUID with commands:

VBoxManage list hdds | tail
VBoxManage closemedium disk UUID --delete"
    fi
    vagrant plugin install vagrant-persistent-storage
    cat > Vagrantfile <<EOF
Vagrant.configure("2") do |config|
    config.vm.box = "centos/7"
    config.vm.hostname = "$host"
    config.vm.network "private_network", ip: "$ip"
    config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--audio", "none"]
        # https://stackoverflow.com/a/36959857/3075806
        v.customize ["setextradata", :id, "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled", "0"]
        # If you see network restart issues, try this:
        # https://github.com/mitchellh/vagrant/issues/8373
        # v.customize ["modifyvm", :id, "--nictype1", "virtio"]
        #
        # Depends on host configuration
        # v.memory = 8192
        # v.cpus = 4
    end

    # Create a disk for docker
    config.persistent_storage.enabled = true
    # so doesn't write signature
    config.persistent_storage.format = false
    # Clearer to add host name to file so that it can be distinguished
    # in VirtualBox Media Manager, which only shows file name, not full path.
    config.persistent_storage.location = "$vdi"
    # so doesn't modify /etc/fstab
    config.persistent_storage.mount = false
    # use whole disk
    config.persistent_storage.partition = false
    config.persistent_storage.size = 102400
    config.persistent_storage.use_lvm = true
    config.persistent_storage.volgroupname = "docker"

    config.ssh.forward_x11 = false

    # don't need vbguest if using nfs
    if Vagrant.has_plugin?("vagrant-vbguest")
        config.vbguest.auto_update = false
    end
    # Mac OS X needs version 4
    config.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: ['rw', 'vers=3', 'tcp', 'nolock', 'fsc', 'actimeo=2']
end
EOF
    vagrant up
}
