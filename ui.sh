#!/usr/bin/env bash
# Print the on-screen text of the TV's current window (quicker than a screenshot for menus).
source "$(dirname "$0")/common.sh"
adb_dev shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1
adb_dev shell cat /sdcard/ui.xml | grep -oE '(text|content-desc)="[^"]+"|focused="true"' | sed 's/^text=//; s/^content-desc=/desc:/' | uniq
