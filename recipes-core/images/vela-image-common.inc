# vela-image-common.inc — shared "completeness" layer for vela-image-<domain>
# variants. Each domain recipe does:
#
#     require recipes-core/images/vela-image.bb
#     require recipes-core/images/vela-image-common.inc
#     IMAGE_INSTALL:append = " <domain-specific packages>"

IMAGE_INSTALL:append = " \
    dbus libpam shadow shadow-base \
    kmod udev util-linux \
    e2fsprogs e2fsprogs-resize2fs dosfstools parted \
    tzdata systemd-analyze logrotate rsyslog \
"

IMAGE_FEATURES:append = " ssh-server-openssh tools-debug ptest-pkgs"
SDKIMAGE_FEATURES:append = " dev-pkgs dbg-pkgs src-pkgs"
TOOLCHAIN_TARGET_TASK:append = " packagegroup-vela-middleware"

IMAGE_INSTALL:append = " \
    packagegroup-core-full-cmdline \
    packagegroup-core-buildessential \
    git make cmake pkgconfig autoconf automake libtool flex bison \
    gcc g++ gdb binutils diffutils patch cpio bc file gawk \
    bzip2 xz gzip tar unzip zip lz4 zstd \
"

IMAGE_INSTALL:append = " \
    python3 python3-pip python3-setuptools python3-wheel \
    python3-numpy python3-requests python3-pyyaml python3-jinja2 \
    python3-jsonschema python3-dateutil python3-six python3-pytz \
    python3-psutil python3-cryptography python3-dbus python3-pyserial \
    python3-periphery python3-pyusb python3-smbus2 python3-spidev \
    python3-gpiod python3-evdev python3-aiohttp \
    python3-pillow python3-matplotlib python3-sqlalchemy \
"

IMAGE_INSTALL:append = " \
    sqlite3 leveldb json-c jansson \
    curl wget rsync lsof socat netcat-openbsd \
    iproute2 iptables tcpdump nmap ethtool traceroute mtr ipcalc \
    net-tools iputils \
    chrony ca-certificates openssl gnupg gnutls rng-tools haveged \
    htop tmux screen nano vim mc procps sysstat iotop \
    usbutils pciutils nvme-cli smartmontools \
    valgrind ltrace perf trace-cmd elfutils logrotate rsyslog audit \
    libgpiod i2c-tools spitools libiio \
"
