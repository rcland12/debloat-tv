# debloat-tv

Disable unwanted apps on Google TV devices over adb, reversibly. Apps are disabled for user 0
(`pm disable-user`), not removed: they stay on the system partition, system updates still
install, and `undo.sh` or a factory reset brings them back. No root.

Lists so far: `packages-chromecast.txt` (Chromecast with Google TV 4K, Android 14) and
`packages-tcl.txt` (TCL 75Q651G, Android 12).

## Setup

Needs bash (Linux or macOS) and a Google TV device with Developer options on.

- adb lives in `tools/platform-tools/` (Google's platform-tools zip, gitignored). Re-download:
  `curl -fsSLo pt.zip https://dl.google.com/android/repository/platform-tools-latest-linux.zip`
  and unzip it into `tools/`.
- Android 12 and older (the TCL) listen on port 5555 once USB debugging is on: use
  `DEVICE=<ip>:5555` and accept the prompt on the TV.
- Android 14 (the Chromecast) uses **Wireless debugging with pairing** instead: Settings > System >
  Developer options > Wireless debugging > Pair device with pairing code, then
  `tools/platform-tools/adb pair <ip:pairport> <code>`. Use the mDNS name from `adb devices`
  (`adb-<serial>-<id>._adb-tls-connect._tcp`) as `DEVICE`, so IP and port changes don't matter.
- `DEVICE` defaults to the contents of `.device` (gitignored, since names can contain the serial).
  `LIST` picks the package list.

## Use

    export DEVICE=192.168.1.x:5555 LIST=packages-tcl.txt
    ./snapshot.sh            # save package state to snapshots/ (run before and after)
    ./debloat.sh             # dry run of the list
    ./debloat.sh --apply     # disable them; each change is logged to changes.log
    ./undo.sh                # re-enable everything in the list
    ./undo.sh <package>      # re-enable one
    ./ui.sh                  # print the text on the TV's screen

A few packages are protected from disabling; `debloat.sh` falls back to `pm uninstall -k --user 0`
(also reversible, and `undo.sh` handles both). Packages listed by `pm list packages` but "not
installed for 0" are dormant already and don't need to be in the list.

After a big system update, run `./debloat.sh` again: updates can re-enable packages.
Each list says what's disabled and why, plus what must never be disabled.

## Home screen

Projectivy Launcher (`com.spocky.projengmenu`, from Play Store) replaces the Google TV home screen.
Install it first, then `./debloat.sh --apply` with either list disables `launcherx` and `setupwraith`. The setup app
has to go too: its `RecoveryActivity` claims Home at a higher priority and swallows the button
when `launcherx` is off. Then make Projectivy the default (on a TV it shows the HDMI inputs as its
first row):

    tools/platform-tools/adb -s "$DEVICE" shell cmd package set-home-activity --user 0 com.spocky.projengmenu/.ui.home.MainActivity

Back to stock: `./undo.sh com.google.android.tungsten.setupwraith` and
`./undo.sh com.google.android.apps.tv.launcherx`, then uninstall Projectivy.

`adb exec-out screencap -p > shots/x.png` takes a screenshot of the TV (`shots/` is gitignored).

## Known limits (Chromecast with Google TV, Android 14)

- **The Netflix remote button can't be remapped.** Google's `chromecastservice` (system uid)
  handles it before any accessibility service sees it, so Button Mapper and
  Projectivy never get the keypress. With Netflix disabled, the button opens its Play Store page.
- **Plex Watch Next posters don't load in Projectivy.** The Plex app publishes them as
  `https://<server LAN IP>:32400/...`, and the server's certificate only covers `*.plex.direct`, so
  Projectivy's strict hostname check rejects them. Not a DNS problem (the URL is a literal IP);
  neither Plex's "Preferred" secure connections nor turning off GDM changed it. The Watch Next row
  is hidden in Projectivy (Edit channels > Watch Next > Visible off).

## License

MIT. See `LICENSE`.
