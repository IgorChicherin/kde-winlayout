# kde-winlayout

Save where your windows are (virtual desktop, position, size, maximized or fullscreen) on KDE Plasma 6
under Wayland, and put them back at login. A small KWin script does the placing, driven over D-Bus.

Tested on Plasma 6.7 / KWin 6.7 on Arch Linux.

## How it works

- `winlayout-save` loads `dump.js` into KWin, which prints every normal window as JSON to the journal.
  The result is written to `~/.local/share/winlayout/layout.json`.
- `winlayout-apply` embeds `layout.json` into `apply.js.tpl` and loads it into KWin as a script.
  The script places each window as it appears, so apps that start late are handled too.
- A window is matched to a saved entry by its app class (`resourceClass`). Several windows of one app
  take the entries in the order they open.
- If a window of a class closes (a splash screen, for example), its entry moves to the next window of that class.

No tools beyond `qdbus6`, `journalctl`, `python3` and `sed` are needed. There is no X11 dependency.

## Install

```sh
./install.sh
```

This copies the scripts to `~/.local/share/winlayout` and adds `~/.config/autostart/winlayout-apply.desktop`.

## Use

1. Arrange your windows on their desktops the way you want.
2. Save: `~/.local/share/winlayout/winlayout-save`
3. Log out and in. The apply script runs at login.
4. Re-apply any time: `~/.local/share/winlayout/winlayout-apply`

Edit `layout.json` by hand to drop a window you do not want restored.
Entries for `org.kde.discover` are skipped in `winlayout-apply`; change that filter if you need to.

### Starting the apps

This project only places windows. The apps must be running. Options:

- Plasma session restore (System Settings, Startup and Shutdown, Desktop Session, Restore previous session)
- `~/.config/autostart` entries, for example `flatpak run org.telegram.desktop`

Do not do both for the same app. Launching Firefox or a terminal twice opens an extra window.

## Known limits

- **Telegram Desktop** ignores resize requests from outside while it draws its own window frame.
  It reaches the right desktop but may keep another size. Reports suggest enabling
  Settings, Advanced, System integration, Window system frame. Not verified with this script.
- **Same-class windows** (two Firefox windows) are matched by opening order, not by content.
  If the app opens them in another order, they swap places.
- **Discord** opens a splash window with the same class first. The script handles this by moving the entry
  to the real window once the splash closes.
- Window rules and session restore of KWin can also move windows; if the two disagree, the last one to act wins.
- Uses KWin scripting through `org.kde.KWin` on D-Bus. Plasma 5 is not supported (`qdbus6`, Plasma 6 script API).

## Uninstall

```sh
./uninstall.sh
```
