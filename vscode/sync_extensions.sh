#!/bin/bash
DOTFILES_EXTENSIONS_FILE="$HOME/dotfiles/vscode/install_extensions.sh"
TEMP_FILE=$(mktemp)

code --list-extensions > "$TEMP_FILE"

while IFS= read -r id; do
    if ! grep -q "code --install-extension $id" "$DOTFILES_EXTENSIONS_FILE"; then
        echo "code --install-extension $id" >> "$DOTFILES_EXTENSIONS_FILE"
    fi
done < "$TEMP_FILE"

rm "$TEMP_FILE"
