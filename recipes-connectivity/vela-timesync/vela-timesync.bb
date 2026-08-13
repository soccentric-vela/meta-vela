SUMMARY = "Vela time synchronisation — enable systemd-timesyncd"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://85-vela-timesync.preset \
"

inherit allarch

do_install() {
    install -d ${D}${systemd_unitdir}/system-preset
    install -m 0644 ${WORKDIR}/85-vela-timesync.preset \
                    ${D}${systemd_unitdir}/system-preset/85-vela-timesync.preset
}

FILES:${PN} = "${systemd_unitdir}/system-preset/85-vela-timesync.preset"
