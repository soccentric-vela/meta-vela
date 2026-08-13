#!/bin/bash
# bootcount-reset.sh — Snapdragon systemd-boot does not use U-Boot bootcount;
# this is a no-op shim retained for interface parity with U-Boot platforms.

set -euo pipefail

logger -t bootcount-reset \
    "Snapdragon boots via systemd-boot (no U-Boot bootcount) — no-op"
exit 0
