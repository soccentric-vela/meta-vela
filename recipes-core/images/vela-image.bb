SUMMARY = "Vela OS — production image for Qualcomm Snapdragon QCS6490"
DESCRIPTION = "Full image with A/B OTA, gRPC/Protobuf, Vela-HAL, hardware \
interface tooling, and connectivity."
HOMEPAGE = "https://github.com/soccentric-vela/Vela-OS"
LICENSE = "MIT"

require recipes-extended/images/core-image-full-cmdline.bb
IMAGE_FEATURES += "ssh-server-openssh"

# OTA / swupdate — install the A/B runtime on the QCS6490 machines
#
# On meta-qcom scarthgap the RB3 Gen 2 is driven by the generic
# qcom-armv8a machine (the qcs6490-rb3gen2-core-kit machine only exists on
# meta-qcom master).  The qcom-armv8a machine also supports the RB3 Gen 2
# and provides systemd-boot/EFI (qcom-common.inc), so the swupdate A/B OTA
# runtime is enabled here.
IMAGE_INSTALL:append:qcom-armv8a = " swupdate swupdate-www vela-swupdate-config"

# Home partition init (persistent /home on the data partition)
IMAGE_INSTALL:append = " vela-data-init"

# Root filesystem expansion (single-partition deployments)
IMAGE_INSTALL:append = " expand-rootfs"

# Connectivity
IMAGE_INSTALL:append = " \
    vela-connectivity iw rfkill bluez5-dev \
"

# gRPC + Protobuf via packagegroup-vela-middleware
IMAGE_INSTALL:append = " packagegroup-vela-middleware sudo"

# Cloud/telemetry package group (not installed by default; add via
# packagegroup-vela-cloud when deployments need MQTT/NTP/cloud connectivity)
# IMAGE_INSTALL:append = " packagegroup-vela-cloud"

# Hardware interface tools
IMAGE_INSTALL:append = " \
    i2c-tools python3-smbus python3-smbus2 \
    spitools python3-spidev \
    libgpiod libgpiod-tools python3-gpiod \
    picocom minicom python3-pyserial \
    usbutils pciutils nvme-cli sg3-utils hdparm mtd-utils \
    can-utils \
    lshw ethtool devmem2 cpupower watchdog sysstat iotop strace \
    v4l-utils evtest python3-periphery vim \
"

# Vela stack
IMAGE_INSTALL:append = " vela-hal vela-services"

# Target debugging and profiling
IMAGE_FEATURES += "tools-debug"
IMAGE_INSTALL:append = " gdbserver perf trace-cmd valgrind"

# Ptest package and runner support
IMAGE_FEATURES += "ptest-pkgs"

# Operator account — locked, SSH-key access only
inherit extrausers
EXTRA_USERS_PARAMS = "\
    useradd -M -s /bin/bash -G sudo vela; \
    usermod -L vela; \
"
