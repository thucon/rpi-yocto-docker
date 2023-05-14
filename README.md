# rpi-yocto-docker

## Overview

In this project we will try to make a custom yocto image that is capable of 
running docker containers on a Raspberry Pi.

## Prerequsites

The following packages should be installed on the host pc (assuming it is
running debian linux flavors)

    apt-get update && apt-get install -y gawk wget git-core diffstat unzip \
        texinfo gcc-multilib build-essential chrpath socat cpio python \
        python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping \
        python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev xterm locales \
        libgmp-dev libmpc-dev libsdl1.2-dev libssl-dev lz4 pylint \
        vim bash-completion screen zstd iproute2 iptables sudo \
        bridge-utils cpu-checker libvirt-clients libvirt-daemon qemu qemu-kvm 

## Getting started

Download the sources (`--recursive` is important)

    git clone --recursive https://github.com/thucon/rpi-yocto-docker
    cd rpi-yocto-docker

Next start the build

    source poky/oe-init-build-env
    bitbake docker-image

## Flash SD card

To flash the SD card use make

    make flash

In case the SD card device name is different, use the `lsblk` command to check
the name and update the `SD_CARD` variable in the `Makefile` (see below).

    SD_CARD=/dev/mmcblk0

## Docker shell

Sometimes it can be better to run the build process in a docker container. This 
especially useful if you are using another linux distribution or another OS.
It is also valuable if you are running CI/CD jobs.

To run the build environment from within a container the following make 
commands can be used

    # build image (can be omitted as image is available on dockerhub)
    make docker-build

    # run shell
    make docker-shell

At this point the docker shell is started 

    $ make docker-shell
    docker run \
        --rm -ti \
        --user $(id -u):$(id -g) \
        -v /home/cvt/work/thucon/projects/rpi-yocto-docker:/home/user/work \
        thucon/yocto-build-image \
        /bin/bash
    user@48ea32cd2fd6:~/work$

Now you just need to source the environment again

    source poky/oe-init-build-env
    bitbake docker-image

**NOTE!** You cannot mix builds from outside and within the container. If you 
build from the container you have to stick to it (otherwise paths in the
yocto environment will not match). To switch between containerized and 
non-containerized builds it is the best to do the following

    # delete build folder
    rm -rf build

    # re-create build folder (local.conf and bblayers.conf)
    git checkout build

## QEMU

It can be beneficial to use `qemu` to run the image in a emulated environment. 
That way you can run and check that all is fine, without the need of real 
hardware.

Change the `MACHINE` in `local.conf`

    MACHINE = "qemuarm64"

Next run `bitbake`

    bitbake docker-image

Run QEMU

    runqemu qemuarm64 nographic

When the QEMU target is started it will create a tunnel interface (tun0) on
address `192.168.7.2`. If you need connection between host and target it can be
done with `ssh` like

    ssh root@192.168.7.2

## QEMU (from docker)

It is possible to run the `qemu` image directly from docker. To run `qemu` from 
docker a special `make` target is available.

Run 

    make qemu-shell

Change the `MACHINE` in `local.conf`

    MACHINE = "qemuarm64"

Next run `bitbake`

    bitbake docker-image

Run QEMU

    runqemu qemuarm64 nographic

**NOTE!** The difference between `docker-shell` and `qemu-shell` is that the 
docker container is started with `--privileged` option in the `qemu-shell` 
case. This is needed to give access to `kvm` and `tun/tap` interfaces.

## Links

    https://hub.mender.io/t/how-to-configure-networking-using-systemd-in-yocto-project/1097


