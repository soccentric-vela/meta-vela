# os-release_%.bbappend — identify this image as "Vela OS".
DISTRO_NAME  = "Vela OS"
DISTRO_VERSION = "${PV}"
PRETTY_NAME = "Vela OS ${PV}"
OS_RELEASE_FIELDS:append = " ID_LIKE"
ID_LIKE = "poky"

do_install:append() {
    cat > ${D}${sysconfdir}/os-release <<OSEOF
ID=vela
ID_LIKE=poky
NAME="Vela OS"
VERSION="${PV}"
VERSION_ID="${PV}"
PRETTY_NAME="Vela OS ${PV}"
HOME_URL="https://vela.dev/"
SUPPORT_URL="https://vela.dev/support"
BUG_REPORT_URL="https://vela.dev/issues"
OSEOF
}
