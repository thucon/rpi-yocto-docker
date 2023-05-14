FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://docker.service \
"

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_SERVICE:${PN} = "docker.service"

do_install:append() {
    # Install systemd unit files
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/docker.service ${D}${systemd_system_unitdir}
}

FILES:${PN} += "${systemd_unitdir}/*"
