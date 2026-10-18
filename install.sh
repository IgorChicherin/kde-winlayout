#!/bin/sh
# Install commands to ~/.local/bin, data to ~/.local/share/winlayout, and add a login autostart entry.
# An existing layout.json is kept.
set -e
here=$(cd "$(dirname "$0")" && pwd)
dest="$HOME/.local/share/winlayout"
bin="$HOME/.local/bin"
mkdir -p "$dest" "$bin" "$HOME/.config/autostart"
install -m 644 "$here/src/dump.js" "$here/src/apply.js.tpl" "$dest/"
install -m 755 "$here/src/winlayout-save" "$here/src/winlayout-apply" "$bin/"
# commands used to live in $dest
rm -f "$dest/winlayout-save" "$dest/winlayout-apply"
cat > "$HOME/.config/autostart/winlayout-apply.desktop" <<DESK
[Desktop Entry]
Type=Application
Name=Window layout
Exec=$bin/winlayout-apply
DESK
echo "installed commands to $bin, data to $dest"
[ -f "$dest/layout.json" ] || echo "no layout yet: arrange your windows, then run $bin/winlayout-save"
