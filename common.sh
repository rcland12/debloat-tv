# Shared settings, sourced by the other scripts.
ADB="$(dirname "$0")/tools/platform-tools/adb"
# Paired wireless-debugging name from `adb devices` (adb finds it by mDNS, so IP and port changes
# don't matter). Set DEVICE or put the name in .device, which is gitignored: it contains the serial.
DEVICE="${DEVICE:-$(cat "$(dirname "$0")/.device" 2>/dev/null)}"
[[ -n "$DEVICE" ]] || { echo "Set DEVICE or write the adb device name to .device"; exit 1; }
# Package list for this device, e.g. LIST=packages-tcl.txt. Required by debloat.sh and undo.sh.
LIST="${LIST:-}"

adb_dev() { "$ADB" -s "$DEVICE" "$@"; }

connect() {
    # ip:port devices (older Android TV, port 5555) need an explicit connect; paired ones are found by mDNS.
    if [[ "$DEVICE" == *:* ]]; then "$ADB" connect "$DEVICE" >/dev/null; else "$ADB" start-server >/dev/null 2>&1; sleep 2; fi
    adb_dev get-state >/dev/null 2>&1 || { echo "Can't reach $DEVICE (Wireless debugging on? If it was re-paired, update .device)"; exit 1; }
}

# Package names from the list file, minus comments and blank lines.
packages() {
    [[ -f "$LIST" ]] || { echo "Set LIST to this device's package list, e.g. LIST=packages-tcl.txt"; exit 1; }
    sed 's/#.*//; s/[[:space:]]*$//; /^$/d' "$LIST"
}
