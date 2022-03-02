#!/usr/bin/env bash

set -euo pipefail

cd `dirname $0`

echo "Please enter your password for sudo access"
sudo echo

vagrant box remove builds/parallels/ubuntu2004-arm64.box -f || true
rm -f builds/parallels/ubuntu2004-arm64.box || true

export PACKER_LOG=2
export PACKER_LOG_PATH=packer/vagrant/packer.log
packer build "packer/vagrant/ubuntu.pkr.hcl"
rm -f packer/vagrant/packer.log

vagrant plugin install vagrant-parallels

# https://gist.github.com/christopher-hopper/5ca9ef78d137ad6d02c0b05fb148e48c
# shellcheck disable=SC2217
sudo tee /etc/sudoers.d/macos-sudoers-vagrant-plugin > /dev/null <<EOF

# vagrant synced-folders https://www.vagrantup.com/docs/synced-folders/nfs.html

Cmnd_Alias VAGRANT_EXPORTS_ADD = /usr/bin/tee -a /etc/exports
Cmnd_Alias VAGRANT_NFSD = /sbin/nfsd restart
Cmnd_Alias VAGRANT_EXPORTS_REMOVE = /usr/bin/sed -E -e /*/ d -ibak /etc/exports

%admin ALL=(root) NOPASSWD: VAGRANT_EXPORTS_ADD, VAGRANT_NFSD, VAGRANT_EXPORTS_REMOVE
EOF

sudo chmod 700 "$TMPDIR"

# https://github.com/hashicorp/vagrant/issues/12583#issuecomment-985787134
sudo curl -o /opt/vagrant/embedded/gems/2.2.19/gems/vagrant-2.2.19/plugins/hosts/darwin/cap/path.rb https://raw.githubusercontent.com/hashicorp/vagrant/42db2569e32a69e604634462b633bb14ca20709a/plugins/hosts/darwin/cap/path.rb || true

echo "Please give nfsd full drive access. Please follow these instructions: (https://blog.docksal.io/nfs-access-issues-on-macos-10-15-catalina-75cd23606913)"
echo "1- Open System Preferences"
echo "2- Go to Security & Privacy → Privacy → Full Disk Access"
echo "3- 🔒 Click the lock to make changes"
echo "4- Click +"
echo "5- Press ⌘ command + shift + G"
echo "6- Enter /sbin/nfsd and click Go, then click Open"

echo "Press any key to continue..."
read -n 1 -s

vagrant up