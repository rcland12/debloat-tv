#!/usr/bin/env bash
# Record the device's package state before and after changes.
set -euo pipefail
source "$(dirname "$0")/common.sh"
connect
out="$(dirname "$0")/snapshots/$(adb_dev shell getprop ro.product.model | tr ' ' _)-$(date +%F-%H%M)"
mkdir -p "$out"
adb_dev shell getprop ro.build.fingerprint   > "$out/build.txt"
adb_dev shell pm list packages -f            | sort > "$out/all.txt"
adb_dev shell pm list packages -s            | sort > "$out/system.txt"
adb_dev shell pm list packages -3            | sort > "$out/user-installed.txt"
adb_dev shell pm list packages -d            | sort > "$out/disabled.txt"
echo "Saved to $out"
