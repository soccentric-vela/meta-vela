SUMMARY = "SWUpdate runtime configuration and A/B OTA helper scripts for Qualcomm Snapdragon"
DESCRIPTION = "Installs swupdate.cfg, slot-detection scripts, web UI drop-in, \
boot-watchdog for rollback counter, health-check service, bootcount-reset, \
and startup wrapper with optional signing + web UI auth."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://swupdate.cfg \
    file://pre-install.sh \
    file://post-install.sh \
    file://swupdate-bootcheck.sh \
    file://swupdate-bootcheck.service \
    file://swupdate-webui.conf \
    file://swupdate-start.sh \
    file://boot-watchdog.sh \
    file://boot-watchdog.service \
    file://bootcount-reset.sh \
    file://bootcount-reset.service \
    file://swupdate-public.pem \
"


inherit systemd

SYSTEMD_SERVICE:${PN} = " \
    swupdate-bootcheck.service \
    boot-watchdog.service \
    bootcount-reset.service \
"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

RDEPENDS:${PN} = "swupdate bash util-linux openssl libubootenv"

do_install() {
    # swupdate main config
    install -d ${D}${sysconfdir}/swupdate
    install -m 0644 ${WORKDIR}/swupdate.cfg \
                    ${D}${sysconfdir}/swupdate/swupdate.cfg

    # A/B slot helper scripts
    install -d ${D}${libdir}/swupdate
    install -m 0755 ${WORKDIR}/pre-install.sh \
                    ${D}${libdir}/swupdate/pre-install.sh
    install -m 0755 ${WORKDIR}/post-install.sh \
                    ${D}${libdir}/swupdate/post-install.sh
    install -m 0755 ${WORKDIR}/swupdate-bootcheck.sh \
                    ${D}${libdir}/swupdate/swupdate-bootcheck.sh
    install -m 0755 ${WORKDIR}/bootcount-reset.sh \
                    ${D}${libdir}/swupdate/bootcount-reset.sh

    # Boot watchdog
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/boot-watchdog.sh \
                    ${D}${sbindir}/boot-watchdog.sh

    # swupdate startup wrapper
    install -m 0755 ${WORKDIR}/swupdate-start.sh \
                    ${D}${sbindir}/swupdate-start.sh

    # systemd units
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/swupdate-bootcheck.service \
                    ${D}${systemd_system_unitdir}/swupdate-bootcheck.service
    install -m 0644 ${WORKDIR}/boot-watchdog.service \
                    ${D}${systemd_system_unitdir}/boot-watchdog.service
    install -m 0644 ${WORKDIR}/bootcount-reset.service \
                    ${D}${systemd_system_unitdir}/bootcount-reset.service

    # Drop-in: replace ExecStart with swupdate-start.sh wrapper
    install -d ${D}${systemd_system_unitdir}/swupdate.service.d
    install -m 0644 ${WORKDIR}/swupdate-webui.conf \
                    ${D}${systemd_system_unitdir}/swupdate.service.d/webui.conf

    # SWUpdate RSA public key for signature verification
    install -m 0644 ${WORKDIR}/swupdate-public.pem \
                    ${D}${sysconfdir}/swupdate/swupdate-public.pem
}

FILES:${PN} += " \
    ${sysconfdir}/swupdate/ \
    ${libdir}/swupdate/ \
    ${sbindir}/boot-watchdog.sh \
    ${sbindir}/swupdate-start.sh \
    ${systemd_system_unitdir}/swupdate-bootcheck.service \
    ${systemd_system_unitdir}/boot-watchdog.service \
    ${systemd_system_unitdir}/bootcount-reset.service \
    ${systemd_system_unitdir}/swupdate.service.d/ \
    ${sysconfdir}/swupdate/swupdate-public.pem \
"
