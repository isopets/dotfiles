function check_gemini_key() {
    unlock-bw || return 1
    if [ -z "$GEMINI_API_KEY" ]; then
        echo "🤖 Searching Bitwarden..."
        local ap=$(bw get password "Gemini-API-Key" 2>/dev/null)
        if [ -n "$ap" ]; then
            echo "export GEMINI_API_KEY=\"$ap\"" >> "$HOME/dotfiles/zsh/.zsh_secrets"
            source "$HOME/dotfiles/zsh/.zsh_secrets"
            return 0
        fi
        echo "⚠️ Not found."
        return 1
    fi
    return 0
}

function save-key() {
    unlock-bw || return 1
    local c=$(pbpaste); local n; local k;
    if [[ "$c" == *":::"* ]]; then
        n=${c%%:::*}; k=${c##*:::}; echo "🚀 Auto-Save: $n"
    else
        k="$c"; echo "📋 Clip: ${k:0:15}..."
        if [[ "$k" =~ ^(sk-|eyJ|AKIA|SG\.|ghp_)[a-zA-Z0-9_-]+ ]]; then
            echo "🤖 Asking AI..."
            local prompt="Suggest name for key '$k'. Service name only."
            local ai_name=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$prompt\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text' | tr -d '[:space:]')
            if [ -n "$ai_name" ]; then echo "💡 Suggestion: $ai_name"; echo -n "Use? (y/n): "; read c; [ "$c" = "y" ] && n="$ai_name"; fi
        fi
        if [ -z "$n" ]; then echo -n "📛 Name: "; read n; fi
    fi
    if [ -n "$n" ]; then
        echo "{\"type\":1,\"name\":\"$n\",\"login\":{\"username\":\"API_KEY\",\"password\":\"$k\"}}" | bw encode | bw create item > /dev/null
        echo "✅ Saved!"; echo -n "$k" | pbcopy
    else
        echo "❌ Aborted."
    fi
}

function bwenv() { unlock-bw || return 1; local p=$(bw get password "$1"); echo "$2=$p" >> .env; echo "✅ Added."; }
function bwfzf() { unlock-bw || return 1; local i=$(bw list items --search "" | jq -r '.[].name' | fzf --prompt="Select Item > "); [ -n "$i" ] && bwenv "$i" "$1"; }
