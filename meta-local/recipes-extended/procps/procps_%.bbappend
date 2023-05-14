do_install:append () {
    # enable NAT routing
    #sed -i "s/#net\/ipv4\/ip_forward=1/net\/ipv4\/ip_forward=1/g" ${D}${sysconfdir}/sysctl.conf
    echo "net.ipv4.ip_forward=1" >> ${D}${sysconfdir}/sysctl.conf

    # reboot on kernel panic
    echo "kernel.panic=10" >> ${D}${sysconfdir}/sysctl.conf
}
