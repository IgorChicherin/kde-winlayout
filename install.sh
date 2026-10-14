#!/bin/sh
# Install scripts to ~/.local/share/winlayout and add a login autostart entry.
# An existing layout.json is kept.
set -e
here=$(cd "$(dirname "$0")" && pwd)
dest="$HOME/.local/share/winlayout"
mkdir -p "$dest" "$HOME/.config/autostart"
install -m 644 "$here/src/dump.js" "$here/src/apply.js.tpl" "$dest/"
install -m 755 "$here/src/winlayout-save" "$here/src/winlayout-apply" "$dest/"
cat > "$HOME/.config/autostart/winlayout-apply.desktop" <<DESK
[Desktop Entry]
Type=Application
Name=Window layout
Exec=$dest/winlayout-apply
DESK
echo "installed to $dest"
[ -f "$dest/layout.json" ] || echo "no layout yet: arrange your windows, then run $dest/winlayout-save"
