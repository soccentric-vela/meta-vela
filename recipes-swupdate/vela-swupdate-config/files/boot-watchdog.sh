#!/bin/bash
# boot-watchdog.sh — early boot rollback watchdog (Snapdragon systemd-boot).
#
# Reads /boot/boot_state and:
#   - If confirmed=true  → nothing to do, slot is healthy.
#   - If confirmed=false → verify boot health, then decrement
#     tries_remaining. If tries_remaining reaches 0 → restore
#     loader.conf.prev and reboot.

set -euo pipefail

BOOT_STATE=/boot/boot_state

if [[ ! -f "${BOOT_STATE}" ]]; then
    exit 0
fi

slot=""
tries_remaining=""
confirmed=""
while IFS='=' read -r key value; do
    case "${key}" in
        slot)            slot="${value}" ;;
        tries_remaining) tries_remaining="${value}" ;;
        confirmed)       confirmed="${value}" ;;
        \#*|"")          : ;;
    esac
done < "${BOOT_STATE}"

if [[ "${confirmed:-false}" == "true" ]]; then
    exit 0
fi

rollback() {
    echo "[boot-watchdog] $* — rolling back" | tee /dev/console
    logger -t boot-watchdog "$* — rolling back"
    mount -o remount,rw /boot
    if [[ -f /boot/loader/loader.conf.prev ]]; then
        cp /boot/loader/loader.conf.prev /boot/loader/loader.conf
    fi
    for f in boot.img qcom/qcs6490-rb3gen2.dtb; do
        [[ -f "/boot/${f}.prev" ]] && cp "/boot/${f}.prev" "/boot/${f}" || true
    done
    rm -f "${BOOT_STATE}" /boot/loader/loader.conf.prev \
          /boot/boot.img.prev /boot/qcom/qcs6490-rb3gen2.dtb.prev
    mount -o remount,ro /boot
    reboot
}

# Health check: kernel command line matches expected slot
CURRENT_ROOT=$(cat /proc/cmdline | tr ' ' '\n' | grep '^root=PARTUUID=' | head -1)
EXPECTED_ROOT=$(grep '^root=' /boot/loader/loader.conf 2>/dev/null | tr -d '\n')

if [[ -z "${EXPECTED_ROOT}" ]]; then
    logger -t boot-watchdog "WARNING: cannot determine expected root PARTUUID"
elif [[ "${CURRENT_ROOT}" != "${EXPECTED_ROOT}" ]]; then
    rollback "cmdline mismatch (expected='${EXPECTED_ROOT}' got='${CURRENT_ROOT}')"
fi

# Health check: kernel + DTB integrity
INTEGRITY_OK=true
for f in boot.img qcom/qcs6490-rb3gen2.dtb; do
    if [[ ! -f "/boot/${f}" ]]; then
        INTEGRITY_OK=false
        logger -t boot-watchdog "${f} missing after boot"
        break
    fi
    SIZE=$(stat -c%s "/boot/${f}" 2>/dev/null || echo 0)
    case "${f}" in
        boot.img)
            MIN=$((1024 * 1024))
            MAX=$((50 * 1024 * 1024))
            ;;
        *.dtb)
            MIN=$((10 * 1024))
            MAX=$((5 * 1024 * 1024))
            ;;
    esac
    if [[ "${SIZE}" -lt "${MIN}" ]] || [[ "${SIZE}" -gt "${MAX}" ]]; then
        INTEGRITY_OK=false
        logger -t boot-watchdog "${f} size ${SIZE} bytes outside [${MIN}, ${MAX}]"
        break
    fi
done

mount -o remount,rw /boot

if [[ "${INTEGRITY_OK}" != "true" ]]; then
    sed -i "s/tries_remaining=.*/tries_remaining=0/" "${BOOT_STATE}"
    mount -o remount,ro /boot
    rollback "kernel/DTB integrity check failed"
fi

TRIES=$(( ${tries_remaining:-0} - 1 ))

if [[ "${TRIES}" -le 0 ]]; then
    mount -o remount,ro /boot
    rollback "tries_remaining exhausted"
else
    sed -i "s/tries_remaining=.*/tries_remaining=${TRIES}/" "${BOOT_STATE}"
    mount -o remount,ro /boot
fi
