#!/bin/bash
# Installs Tiling Shell GNOME extension and applies custom snap layouts.
# Run once after a fresh Fedora install. Requires logout/login on Wayland to activate.

SCHEMA_DIR="$HOME/.local/share/gnome-shell/extensions/tilingshell@ferrarodomenico.com/schemas"

echo "Installing Tiling Shell..."
pip install gnome-extensions-cli --break-system-packages -q
~/.local/bin/gext install tilingshell@ferrarodomenico.com
~/.local/bin/gext enable tilingshell@ferrarodomenico.com

echo "Applying layouts..."
gsettings --schemadir "$SCHEMA_DIR" \
  set org.gnome.shell.extensions.tilingshell layouts-json \
  '[
    {"id":"Two Portrait","tiles":[{"x":0,"y":0,"width":0.5,"height":0.5,"groups":[1,2]},{"x":0,"y":0.5,"width":0.5,"height":0.5,"groups":[1,3]},{"x":0.5,"y":0,"width":0.5,"height":0.5,"groups":[2,4]},{"x":0.5,"y":0.5,"width":0.5,"height":0.5,"groups":[3,4]}]},
    {"id":"Half & Half","tiles":[{"x":0,"y":0,"width":0.5,"height":1,"groups":[1]},{"x":0.5,"y":0,"width":0.5,"height":1,"groups":[1]}]},
    {"id":"Top & Bottom","tiles":[{"x":0,"y":0,"width":1,"height":0.5,"groups":[1]},{"x":0,"y":0.5,"width":1,"height":0.5,"groups":[1]}]},
    {"id":"Main + Side","tiles":[{"x":0,"y":0,"width":0.67,"height":1,"groups":[1]},{"x":0.67,"y":0,"width":0.33,"height":1,"groups":[1]}]},
    {"id":"3 Columns","tiles":[{"x":0,"y":0,"width":0.33,"height":1,"groups":[1]},{"x":0.33,"y":0,"width":0.34,"height":1,"groups":[1,2]},{"x":0.67,"y":0,"width":0.33,"height":1,"groups":[2]}]}
  ]'

echo "Done. Log out and back in to activate on Wayland."
