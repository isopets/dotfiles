#!/bin/bash
FILE="$HOME/dotfiles/vscode/install_extensions.sh"; TEMP=$(mktemp)
code --list-extensions > "$TEMP"
while read id; do grep -q "$id" "$FILE" || echo "code --install-extension $id" >> "$FILE"; done < "$TEMP"
rm "$TEMP"
