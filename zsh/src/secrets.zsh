function load_secrets() {
    [ -n "$GEMINI_API_KEY" ] && return 0
    local s=$(security find-generic-password -w -s "cockpit-bw-session" 2>/dev/null)
    if [ -n "$s" ]; then
        export BW_SESSION="$s"
        bw list folders --session "$s" >/dev/null 2>&1 && _fetch_keys && return 0
        unset BW_SESSION
    fi
    local bw_status=$(bw status | jq -r .status)
    [ "$bw_status" = "unauthenticated" ] && echo "⛔️ Login required." && return 1
    echo "🔐 Unlocking..."
    local mp=$(gum input --password --placeholder "Master Password")
    [ -z "$mp" ] && return 1
    local ns=$(echo "$mp" | bw unlock --raw 2>/dev/null)
    if [ -n "$ns" ]; then
        export BW_SESSION="$ns"
        security add-generic-password -U -a "$USER" -s "cockpit-bw-session" -w "$ns"
        _fetch_keys
    else
        echo "❌ Failed."
        return 1
    fi
}
function _fetch_keys() {
    local k=$(bw get password "Gemini API Key" --session "$BW_SESSION" 2>/dev/null)
    [ -z "$k" ] && k=$(bw get password "Cockpit | Gemini API Key" --session "$BW_SESSION" 2>/dev/null)
    [ -n "$k" ] && export GEMINI_API_KEY="$k"
}
function save-key() {
    local s=$(pbpaste)
    [ -z "$s" ] && echo "📋 Empty clipboard." && return 1
    local n=$(gum input --placeholder "Key Name")
    [ -z "$n" ] && return 1
    [ -z "$BW_SESSION" ] && load_secrets
    [ -z "$BW_SESSION" ] && return 1
    echo "$s" | bw encode | bw create item --name "$n" --login-username "apikey" --login-password "$s" --session "$BW_SESSION" >/dev/null && echo "✅ Saved."
}
alias sk="save-key"
