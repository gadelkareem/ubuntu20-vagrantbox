# Ubuntu 20.04 Vagrant Box
Vagrant ARM64 Ubuntu 20.04 box built using packer and parallels for Apple Silicon Macbook M1, with Parallels guest tools already installed.

# Build and run the box:
```shell
git clone git@github.com:gadelkareem/ubuntu20-vagrantbox.git
./init.sh
```
This will build the box using cloud-init and ansible then does a `vagrant up`. The root directory will be mounted to `/var/www/application` which you can change in the Vagrantfile.

The box is available on [Vagrant Cloud](https://app.vagrantup.com/gadelkareem/boxes/ubuntu-20.04-parallels)

---
Big thanks to [@craig-m-unsw] for his gist https://gist.github.com/craig-m-unsw/f457a9a189cd939a73b7d215c22b96e2