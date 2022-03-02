
packer {
  required_version = ">= 1.7.10"
}

variable "extra_vars" {
  type    = string
  default = ""
}

variable "box_name" {
  type    = string
  default = "ubuntu2004-arm64.box"
}

variable "iso_checksum" {
  type    = string
  default = "d6fea1f11b4d23b481a48198f51d9b08258a36f6024cb5cec447fe78379959ce"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04.3-live-server-arm64.iso"
}

# boot_command issues solved by:
# https://github.com/hashicorp/packer/issues/9115
source "parallels-iso" "ubuntu-pa" {
  boot_command = [
    "<up>c<wait><bs><bs>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"<enter><wait>",
    "initrd /casper/initrd<enter><wait>", "boot<enter>"
  ]
  boot_wait              = "5s"
  communicator           = "ssh"
  cpus                   = "4"
  disk_size              = "200000"
  guest_os_type          = "ubuntu"
  iso_checksum           = "${var.iso_checksum}"
  iso_url                = "${var.iso_url}"
  memory                 = "4096"
  shutdown_command       = "sudo shutdown now"
  ssh_username           = "vagrant"
  ssh_password           = "vagrant"
  ssh_port               = "22"
  ssh_timeout            = "2h"
  parallels_tools_mode   = "attach"
  #  parallels_tools_guest_path = "/tmp/parallels-tools-lin.iso"
  parallels_tools_flavor = "lin-arm"
  prlctl_version_file    = ".prlctl_version"
  vm_name                = "ubuntu-pa"
  http_directory         = "packer/vagrant/http"
}


build {
  sources = ["source.parallels-iso.ubuntu-pa"]

  provisioner "shell" {
    inline  = ["sudo cloud-init status --wait"]
    timeout = "15m0s"
  }
  provisioner "shell" {
    inline = [
      #      uncomment the following lines if you are using parallels_tools_guest_path
      #      "sudo tail -f /dev/null",
      #      "sudo mkdir -p /media/parallels-tools",
      #      "sudo mount -o loop -o exec /tmp/parallels-tools-lin.iso /media/parallels-tools",
      #      "cd /media/parallels-tools && sudo  ./install --install-unattended-with-deps"

      "sudo mkdir -p /media/parallels-tools", "sudo umount /cdrom /dev/cdrom /dev/sr1 || true",
      "sudo mount -o exec /dev/sr0 /media/parallels-tools || sudo mount -o exec /dev/sr1 /media/parallels-tools",
      "sudo /media/parallels-tools/install --install-unattended-with-deps",
      #      "tail -f /dev/null",
    ]
    timeout = "15m0s"
  }

  provisioner "shell" {
    expect_disconnect = true
    inline            = ["sudo reboot now"]
    pause_before      = "10s"
    timeout           = "10m0s"
  }

  provisioner "ansible-local" {
    max_retries             = 5
    playbook_dir            = "packer/vagrant/ansible"
#    galaxy_file              = "packer/vagrant/ansible/requirements.yml"
    playbook_file            = "packer/vagrant/ansible/vagrant-playbook.yml"
    timeout                 = "10m0s"
    inventory_groups        = ["base"]
    clean_staging_directory = true
  }

  provisioner "shell" {
    expect_disconnect = true
    inline            = ["sudo reboot now"]
    pause_before      = "10s"
    timeout           = "10m0s"
  }

  post-processor "vagrant" {
    keep_input_artifact = false
    compression_level   = 0
    output              = "builds/parallels/${var.box_name}"
  }

}