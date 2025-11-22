#!/bin/bash
LIST="$HOME/dotfiles/chrome/extensions.txt"; TEMP=$(mktemp)
ROOTS=(
    "$HOME/Library/Application Support/Google/Chrome"
    "$HOME/Library/Application Support/BraveSoftware/Brave-Browser"
    "$HOME/Library/Application Support/Microsoft Edge"
)
echo "🔍 Scanning..."
for r in "${ROOTS[@]}"; do
    [ -d "$r" ] && find "$r" -type d -name "Extensions" 2>/dev/null | while read ed; do
        for ep in "$ed"/*; do
            [ -d "$ep" ] && {
                id=$(basename "$ep"); man=$(find "$ep" -name "manifest.json" -maxdepth 2 | head -n 1)
                [ -f "$man" ] && echo "$id # $(jq -r '.name' "$man")" >> "$TEMP"
            }
        done
    done
done
sort -u "$TEMP" | while read l; do
    id=$(echo "$l"|awk '{print $1}'); n=$(echo "$l"|cut -d'#' -f2-)
    if ! grep -q "$id" "$LIST"; then
        echo "New: $n"; echo -n "Add? (y/n): "; read c < /dev/tty
        [ "$c" = "y" ] && { echo "$id # $n" >> "$LIST"; ~/dotfiles/chrome/install_chrome_extensions_flexible.sh; }
    fi
done
rm "$TEMP"
