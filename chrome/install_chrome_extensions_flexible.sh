#!/bin/bash
FILE="$HOME/dotfiles/chrome/extensions.txt"; URL="https://clients2.google.com/service/update2/crx"
DIRS=(
    "$HOME/Library/Application Support/Google/Chrome/External Extensions"
    "$HOME/Library/Application Support/BraveSoftware/Brave-Browser/External Extensions"
    "$HOME/Library/Application Support/Microsoft Edge/External Extensions"
)
while IFS= read -r l; do
    [[ "$l" =~ ^#.* || -z "$l" ]] && continue
    id=$(echo "$l"|awk '{print $1}'); tag=$(echo "$l"|grep -o '\[.*\]')
    all=false; [[ -z "$tag" || "$tag" == *"[ALL]"* ]] && all=true
    for d in "${DIRS[@]}"; do
        p=$(dirname "$d"); b=$(basename "$(dirname "$d")" | tr '[:lower:]' '[:upper:]')
        if [ -d "$p" ]; then
            if [ "$all" = true ] || [[ "$tag" == *"$b"* ]]; then
                mkdir -p "$d"; echo "{\"external_update_url\": \"$URL\"}" > "$d/$id.json"
            fi
        fi
    done
done < "$FILE"
echo "✅ Browser extensions configured."
