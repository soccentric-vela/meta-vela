SUMMARY = "Vela cloud/telemetry package group"
DESCRIPTION = "Meta-package for cloud connectivity and telemetry tooling — \
MQTT client/broker (mosquitto), NTP-based time synchronisation (chrony), \
and HTTP transport (curl). Not installed by default (see vela-image.bb); \
add packagegroup-vela-cloud to IMAGE_INSTALL for deployments that need \
cloud/telemetry connectivity."
HOMEPAGE = "https://github.com/soccentric-vela/Vela-OS"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit packagegroup

PACKAGES = "${PN}"
ALLOW_EMPTY:${PN} = "1"

RDEPENDS:${PN} = " \
    mosquitto \
    mosquitto-clients \
    chrony \
    curl \
"
