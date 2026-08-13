# Persistent journal + explicit NTP for Vela devices.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://journald-vela.conf \
    file://timesyncd-vela.conf \
"

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/journald.conf.d
    install -m 0644 ${WORKDIR}/journald-vela.conf \
                    ${D}${sysconfdir}/systemd/journald.conf.d/vela.conf

    install -d ${D}${sysconfdir}/systemd/timesyncd.conf.d
    install -m 0644 ${WORKDIR}/timesyncd-vela.conf \
                    ${D}${sysconfdir}/systemd/timesyncd.conf.d/vela.conf
}

FILES:${PN} += " \
    ${sysconfdir}/systemd/journald.conf.d/ \
    ${sysconfdir}/systemd/timesyncd.conf.d/ \
"

INSANE_SKIP:${PN} += "empty-dirs"
