function unlock-bw() {
    if bw status | grep -q "unlocked"; then return 0; fi
    if [ -f "$BW_SESSION_FILE" ]; then export BW_SESSION=$(cat "$BW_SESSION_FILE"); if bw status | grep -q "unlocked"; then return 0; fi; fi
    echo "🔐 Bitwarden locked."
    local mp=""; if command -v security >/dev/null; then mp=$(security find-generic-password -a "$USER" -s "dotfiles-bw-master" -w 2>/dev/null); fi
    if [ -z "$mp" ]; then echo -n "🔑 Master Password: "; read -s mp; echo ""; if [ -n "$mp" ]; then security add-generic-password -a "$USER" -s "dotfiles-bw-master" -w "$mp" -U; fi; fi
    local k=$(echo "$mp" | bw unlock --raw); if [ -n "$k" ]; then echo "$k" > "$BW_SESSION_FILE"; export BW_SESSION="$k"; echo "✅ Unlocked."; else echo "❌ Failed."; return 1; fi
}

function save-key() {
    unlock-bw || return 1
    local c=$(pbpaste); local n; local k
    
    if [[ "$c" == *":::"* ]]; then
        n=${c%%:::*}; k=${c##*:::}; echo "🚀 Auto-Save: $n"
    else
        k="$c"
        echo "📋 Clip: ${k:0:15}..."
        # AIによる自動命名
        if [[ "$k" =~ ^(sk-|eyJ|AKIA|SG\.|ghp_)[a-zA-Z0-9_-]+ ]]; then
            if [ -n "$GEMINI_API_KEY" ]; then
                echo "🤖 Naming..."
                local p="Suggest name for key '$k'. Service name only."
                local an=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$p\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text' | tr -d '[:space:]')
                [ -n "$an" ] && echo "💡 AI: $an" && echo -n "Use? (y/n): " && read y && [ "$y" = "y" ] && n="$an"
            fi
        fi
        if [ -z "$n" ]; then echo -n "📛 Name: "; read n; fi
    fi

    if [ -n "$n" ] && [ -n "$k" ]; then
        echo "{\"type\":1,\"name\":\"$n\",\"login\":{\"username\":\"API_KEY\",\"password\":\"$k\"}}" | bw encode | bw create item > /dev/null
        echo "✅ Saved as: $n!"
        echo -n "$k" | pbcopy
    else
        echo "❌ Aborted."
    fi
}

function bwenv() { unlock-bw || return 1; local p=$(bw get password "$1"); echo "$2=$p" >> .env; echo "✅ Added."; }
function bwfzf() { unlock-bw || return 1; local i=$(bw list items --search "" | jq -r '.[].name' | fzf --prompt="Select Item > "); [ -n "$i" ] && bwenv "$i" "$1"; }