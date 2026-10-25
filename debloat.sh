#!/usr/bin/env bash
# Disable every package in packages.txt for user 0. Dry run unless --apply.
# Disabling leaves the app on the system partition, so undo.sh or a factory reset restores it.
set -euo pipefail
source "$(dirname "$0")/common.sh"
connect
apply=false; [[ "${1:-}" == "--apply" ]] && apply=true
installed="$(adb_dev shell pm list packages | sed 's/^package://')"
for pkg in $(packages); do
    if ! grep -qx "$pkg" <<<"$installed"; then echo "skip  $pkg (not installed)"; continue; fi
    if $apply; then
        result="$(adb_dev shell pm disable-user --user 0 "$pkg" 2>&1 | tr -d '\r' || true)"
        # Some packages are protected from disabling; hide them for user 0 instead (undo: cmd package install-existing).
        if ! grep -q "new state: disabled" <<<"$result"; then
            result="disable refused; uninstall --user 0: $(adb_dev shell pm uninstall -k --user 0 "$pkg" 2>&1 | tr -d '\r' || true)"
        fi
        echo "$(date -Is) $pkg $result" | tee -a "$(dirname "$0")/changes.log"
    else
        echo "would disable $pkg"
    fi
done
$apply || echo "Dry run. Rerun with --apply to make changes."
