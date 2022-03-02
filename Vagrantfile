# -*- mode: ruby -*-
# vi: set ft=ruby :
#

Vagrant.require_version ">= 2.2.18"

Vagrant.configure("2") do |config|
    config.vm.box = "builds/parallels/ubuntu2004-arm64.box"
    config.ssh.forward_agent = true
    config.vm.box_check_update = false
    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"
    config.ssh.insert_key = true
    config.ssh.keep_alive = true
    config.ssh.compression = false

    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.synced_folder ".", "/var/www/application", :nfs => { group: "www-data", owner: "vagrant" }, :mount_options => ['nolock,vers=3,udp,noatime,actimeo=1'], type: :nfs, linux__nfs_options: ['no_root_squash'], map_uid: 0, map_gid: 0

    ######vm1
    config.vm.define "vm1" do |services|
        services.vm.network "private_network", ip: '192.168.33.10', auto_correct: true
        services.vm.network "forwarded_port", guest: 22, host: 2200, id: 'ssh', auto_correct: true

        services.vm.provider "parallels" do |v|
            v.check_guest_tools = true
            v.update_guest_tools = false
            v.memory = 8192
            v.cpus = 6
        end
    end
end
