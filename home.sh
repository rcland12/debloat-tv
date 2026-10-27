#!/usr/bin/env bash
# Switch the home screen: ./home.sh google | projectivy
# google: re-enables the stock Google TV home (launcherx) and the setup app, whose settings pages
# (account > Apps & services, Apps only mode) show "Unavailable" without it. projectivy: makes
# Projectivy the default and disables both again (the setup app hijacks Home when launcherx is off).
# The rest of the debloat is untouched either way.
set -euo pipefail
source "$(dirname "$0")/common.sh"
connect
GOOGLE=(com.google.android.apps.tv.launcherx com.google.android.tungsten.setupwraith)
case "${1:-}" in
    google)
        for p in "${GOOGLE[@]}"; do adb_dev shell pm enable "$p" >/dev/null; done
        home="${GOOGLE[0]}/.home.HomeActivity" ;;
    projectivy)
        home=com.spocky.projengmenu/.ui.home.MainActivity ;;
    *) echo "Usage: $0 google|projectivy"; exit 1 ;;
esac
adb_dev shell cmd package set-home-activity --user 0 "$home"
if [[ "$1" == projectivy ]]; then
    for p in "${GOOGLE[@]}"; do adb_dev shell pm disable-user --user 0 "$p" >/dev/null; done
fi
adb_dev shell input keyevent KEYCODE_HOME
echo "Home is now $1"
