SUMMARY = "A small image based on core-image-minimal, with docker capabilities"

IMAGE_INSTALL = "packagegroup-core-boot \
                ${CORE_IMAGE_EXTRA_INSTALL} \
                docker-ce \
                python3 \
                python3-docker-compose \
                os-release \
                vim \
                nano \
                make \
                htop \
                git \
                procps \
                iproute2 \
                iproute2-tc \
"

# if the distro has systemd it already contains clients for ntp, dhcp etc.
IMAGE_INSTALL:append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", "", " ntp ntpdate dhcpcd", d)}"

IMAGE_FEATURES:append = " ssh-server-openssh"
CORE_IMAGE_EXTRA_INSTALL += "openssh-sftp openssh-sftp-server"

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE:append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "", d)}"
