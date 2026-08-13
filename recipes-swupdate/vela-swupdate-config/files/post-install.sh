#!/bin/bash
# SWUpdate post-install script — included in every .swu package
#
# Updates the Snapdragon boot config so that UEFI/systemd-boot boots the
# newly written slot on the next reboot, writes boot_state for the watchdog,
# and backs up the boot config for rollback recovery.

set -euo pipefail

TARGET_SLOT=$(cat /run/swupdate-target-slot)
TARGET_DEV=$(cat  /run/swupdate-target-dev)

echo "[swupdate post-install] activating slot ${TARGET_SLOT} (${TARGET_DEV})"

TARGET_PARTUUID=$(blkid -s PARTUUID -o value "${TARGET_DEV}")
if [[ -z "${TARGET_PARTUUID}" ]]; then
    echo "[swupdate post-install] ERROR: cannot read PARTUUID from ${TARGET_DEV}" >&2
    exit 1
fi

mount -o remount,rw /boot

# systemd-boot loader.conf selects the default entry; update the root= PARTUUID.
if [[ -f /boot/loader/loader.conf ]]; then
    cp /boot/loader/loader.conf /boot/loader/loader.conf.prev
    sed -i "s|root=PARTUUID=[a-fA-F0-9-]*|root=PARTUUID=${TARGET_PARTUUID}|" \
        /boot/loader/loader.conf
fi

# Write boot_state for the watchdog — 3 tries before automatic rollback
printf 'slot=%s\ntries_remaining=3\nconfirmed=false\n' "${TARGET_SLOT}" \
    > /boot/boot_state

mount -o remount,ro /boot

echo "[swupdate post-install] loader.conf → root=PARTUUID=${TARGET_PARTUUID}"
echo "[swupdate post-install] boot_state written (slot=${TARGET_SLOT} tries=3)"

# Snapdragon UEFI boots systemd-boot directly (no U-Boot fw_setenv);
# the boot_state watchdog handles rollback.
rm -f /dev/swupdate-inactive \
      /run/swupdate-target-slot \
      /run/swupdate-target-dev
