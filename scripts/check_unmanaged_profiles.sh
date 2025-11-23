#!/bin/bash
VDIR="$HOME/Library/Application Support/Code/User/profiles"
LIST="$HOME/dotfiles/vscode/profile_list.txt"
[ ! -f "$LIST" ] && exit 0
MANAGED=("Default"); while IFS=: read -r n f; do [[ "$n" =~ ^[^#] ]] && MANAGED+=("$n"); done < "$LIST"
if [ -d "$VDIR" ]; then
    for p in "$VDIR"/*; do
        [ -d "$p" ] || continue
        pn=$(basename "$p"); match=false
        for m in "${MANAGED[@]}"; do [[ "$m" == "$pn" ]] && match=true && break; done
        [ "$match" = false ] && echo "🚨 Unmanaged Profile: '$pn' detected!"
    done
fi
