SUMMARY = "Vela persistent home directory initialisation"
DESCRIPTION = "Creates /home/vela on first boot after the persistent home \
partition (p4) is mounted at /home."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://vela-data-init.sh \
    file://vela-data-init.service \
"


inherit systemd

SYSTEMD_SERVICE:${PN}     = "vela-data-init.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

RDEPENDS:${PN} = "bash util-linux parted e2fsprogs-resize2fs"

do_install() {
    install -d ${D}${libdir}/vela-data-init
    install -m 0755 ${WORKDIR}/vela-data-init.sh \
                    ${D}${libdir}/vela-data-init/vela-data-init.sh

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/vela-data-init.service \
                    ${D}${systemd_system_unitdir}/vela-data-init.service
}

FILES:${PN} += " \
    ${libdir}/vela-data-init/ \
    ${systemd_system_unitdir}/vela-data-init.service \
"
