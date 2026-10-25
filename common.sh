# Shared settings, sourced by the other scripts.
ADB="$(dirname "$0")/tools/platform-tools/adb"
# Paired wireless-debugging name from `adb devices` (adb finds it by mDNS, so IP and port changes
# don't matter). Set DEVICE or put the name in .device, which is gitignored: it contains the serial.
DEVICE="${DEVICE:-$(cat "$(dirname "$0")/.device" 2>/dev/null)}"
[[ -n "$DEVICE" ]] || { echo "Set DEVICE or write the adb device name to .device"; exit 1; }
LIST="${LIST:-$(dirname "$0")/packages.txt}"

adb_dev() { "$ADB" -s "$DEVICE" "$@"; }

connect() {
    "$ADB" start-server >/dev/null 2>&1; sleep 2  # give mDNS discovery a moment
    adb_dev get-state >/dev/null 2>&1 || { echo "Can't reach $DEVICE (Wireless debugging on? If it was re-paired, update .device)"; exit 1; }
}

# Package names from the list file, minus comments and blank lines.
packages() { sed 's/#.*//; s/[[:space:]]*$//; /^$/d' "$LIST"; }
