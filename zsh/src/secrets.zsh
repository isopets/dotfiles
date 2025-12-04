# Load Secrets Logic
function load_secrets() {
    if [ -n "$GEMINI_API_KEY" ]; then return 0; fi
    
    local stored_session=$(security find-generic-password -w -s "cockpit-bw-session" 2>/dev/null)
    if [ -n "$stored_session" ]; then
        export BW_SESSION="$stored_session"
        if bw list folders --session "$BW_SESSION" >/dev/null 2>&1; then
            _fetch_keys; return 0
        fi
    fi

    echo "🔐 Unlocking Vault..."
    local new_session=$(bw unlock --raw)
    if [ $? -eq 0 ] && [ -n "$new_session" ]; then
        export BW_SESSION="$new_session"
        security add-generic-password -U -a "$USER" -s "cockpit-bw-session" -w "$BW_SESSION"
        _fetch_keys
    else
        echo "❌ Unlock failed."
        return 1
    fi
}

function _fetch_keys() {
    local project="Global"
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        project=$(basename "$(git rev-parse --show-toplevel)")
    fi

    # 1. Project Specific
    local key=$(bw get password "$project | Gemini API Key" --session "$BW_SESSION" 2>/dev/null)
    # 2. Default
    [ -z "$key" ] && key=$(bw get password "Gemini API Key" --session "$BW_SESSION" 2>/dev/null)
    
    if [ -n "$key" ]; then
        export GEMINI_API_KEY="$key"
        echo "✅ Secrets loaded."
    else
        echo "⚠️  Gemini Key not found."
    fi
}

function save-key() {
    local secret=$(pbpaste)
    [ -z "$secret" ] && echo "❌ Clipboard empty." && return 1
    
    local service="Unknown"
    [[ "$secret" =~ ^AIza ]] && service="Gemini"
    [[ "$secret" =~ ^sk- ]] && service="OpenAI"
    [[ "$secret" =~ ^gh ]] && service="GitHub"

    local project="Global"
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 && project=$(basename "$(git rev-parse --show-toplevel)")
    
    local auto_name="$project | $service API Key"
    [ -z "$BW_SESSION" ] && load_secrets >/dev/null
    
    local name=$(gum input --value "$auto_name" --placeholder "Name")
    [ -z "$name" ] && return 1
    
    echo "$secret" | bw encode | bw create item --name "$name" --login-username "apikey" --login-password "$secret" --session "$BW_SESSION" > /dev/null
    echo "✅ Saved: $name"
    echo "" | pbcopy
}
alias sk="save-key"
