do_install:append() {
    echo ""                             >> ${D}${sysconfdir}/ntp.conf
    echo "# custom timeservers"         >> ${D}${sysconfdir}/ntp.conf
    echo "server 0.pool.ntp.org iburst" >> ${D}${sysconfdir}/ntp.conf
    echo "server 1.pool.ntp.org iburst" >> ${D}${sysconfdir}/ntp.conf
    echo "server 2.pool.ntp.org iburst" >> ${D}${sysconfdir}/ntp.conf
    echo "server 3.pool.ntp.org iburst" >> ${D}${sysconfdir}/ntp.conf
}
