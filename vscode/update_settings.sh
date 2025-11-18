#!/bin/bash
DOT_VSCODE="$HOME/dotfiles/vscode"
SRC="$DOT_VSCODE/source"
DEST="$DOT_VSCODE/profiles"
COMMON="$SRC/_common.json"
LIST="$DOT_VSCODE/profile_list.txt"

mkdir -p "$DEST"

while IFS=: read -r profile_name diff_file; do
    [[ "$profile_name" =~ ^#.*$ ]] && continue
    [[ -z "$profile_name" ]] && continue

    output_dir="$DEST/$profile_name"
    mkdir -p "$output_dir"
    
    if [ "$diff_file" != "none" ] && [ -f "$SRC/$diff_file" ]; then
        jq -s '.[0] * .[1]' "$COMMON" "$SRC/$diff_file" > "$output_dir/settings.json"
    else
        cp "$COMMON" "$output_dir/settings.json"
    fi
done < "$LIST"
echo "✅ Settings Updated."
