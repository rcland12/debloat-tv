#!/usr/bin/env bash
# Re-enable every package in packages.txt (or one package: ./undo.sh com.example.app).
set -euo pipefail
source "$(dirname "$0")/common.sh"
connect
for pkg in ${1:-$(packages)}; do
    # install-existing brings back anything debloat.sh had to uninstall for user 0; it's a no-op otherwise.
    adb_dev shell cmd package install-existing --user 0 "$pkg" >/dev/null 2>&1 || true
    echo "$(date -Is) $pkg $(adb_dev shell pm enable --user 0 "$pkg" 2>&1 | tr -d '\r')" | tee -a "$(dirname "$0")/changes.log"
done
