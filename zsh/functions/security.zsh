function check_gemini_key() {
    unlock-bw || return 1
    if [ -z "$GEMINI_API_KEY" ]; then
        echo "🤖 Searching Bitwarden..."
        local ap=$(bw get password "Gemini-API-Key" 2>/dev/null)
        if [ -n "$ap" ]; then echo "export GEMINI_API_KEY=\"$ap\"" >> "$HOME/dotfiles/zsh/.zsh_secrets"; source "$HOME/dotfiles/zsh/.zsh_secrets"; return 0; fi
        echo "⚠️ Not found. Please create 'Gemini-API-Key' in Bitwarden."
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
        k="$c"; echo "📋 Clip: ${k:0:15}..."; echo -n "📛 Name: "; read n
    fi
    if [ -n "$n" ] && [ -n "$k" ]; then echo "{\"type\":1,\"name\":\"$n\",\"login\":{\"username\":\"API_KEY\",\"password\":\"$k\"}}" | bw encode | bw create item > /dev/null; echo "✅ Saved as: $n!"; echo -n "$k" | pbcopy; else echo "❌ Save aborted."; fi
}
function bwenv() { unlock-bw || return 1; local p=$(bw get password "$1"); echo "$2=$p" >> .env; echo "✅ Added."; }
function bwfzf() { unlock-bw || return 1; local i=$(bw list items --search "" | jq -r '.[].name' | fzf --prompt="Select Item > "); [ -n "$i" ] && bwenv "$i" "$1"; }
