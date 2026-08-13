#!/bin/bash
# swupdate-bootcheck.sh — health check that confirms OTA or triggers rollback.
#
# Runs after local-fs.target (before network.target) to ensure the health
# check completes BEFORE network services start. If the health check fails,
# the system rolls back before any network exposure.

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

sleep 5

HEALTH_OK=true

# Verify kernel/DTB files are intact
for f in boot.img qcom/qcs6490-rb3gen2.dtb; do
    if [[ ! -f "/boot/${f}" ]]; then
        HEALTH_OK=false
        logger -t swupdate-bootcheck "${f} missing after boot"
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
        HEALTH_OK=false
        logger -t swupdate-bootcheck \
            "${f} size ${SIZE} bytes outside [${MIN}, ${MAX}]"
        break
    fi
done

if [[ "${HEALTH_OK}" == "true" ]]; then
    mount -o remount,rw /boot
    sed -i 's/confirmed=false/confirmed=true/' "${BOOT_STATE}"
    mount -o remount,ro /boot
    logger -t swupdate-bootcheck "Slot ${slot} confirmed healthy"
else
    logger -t swupdate-bootcheck "Slot ${slot} unhealthy — rolling back"
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
fi
