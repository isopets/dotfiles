#!/bin/bash
SRC="$HOME/dotfiles/vscode/source"; DEST="$HOME/dotfiles/vscode/profiles"
COMMON="$SRC/_common.json"; LIST="$HOME/dotfiles/vscode/profile_list.txt"
mkdir -p "$DEST"
clean_json() { sed -e '/^[[:space:]]*\/\//d' -e 's/[[:space:]]\/\/.*//g' "$1"; }

while IFS=: read -r name diff; do
    [[ "$name" =~ ^#.* || -z "$name" ]] && continue
    odir="$DEST/$name"; mkdir -p "$odir"; ofile="$odir/settings.json"
    [ -f "$ofile" ] && chmod +w "$ofile"
    
    if [ "$diff" != "none" ] && [ -f "$SRC/$diff" ]; then
        jq -s '.[0] * .[1]' <(clean_json "$COMMON") <(clean_json "$SRC/$diff") > "$ofile"
    else clean_json "$COMMON" > "$ofile"; fi
    
    # ヘッダー追加
    temp=$(mktemp)
    echo "// 🛑 DO NOT EDIT! Managed by Dotfiles." > "$temp"
    cat "$ofile" >> "$temp" && mv "$temp" "$ofile"
    
    chmod a-w "$ofile"
done < "$LIST"
echo "✅ Built & Locked."
