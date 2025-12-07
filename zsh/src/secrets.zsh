# =================================================================
# 🔐 Cockpit Security Module (Bitwarden Integration) - v2.2 Clean UI
# =================================================================

function load_secrets() {
    # 1. 既に環境変数にあれば何もしない
    if [ -n "$GEMINI_API_KEY" ]; then return 0; fi

    # 2. Keychain (Mac) から既存セッションを探す
    local s=$(security find-generic-password -w -s "cockpit-bw-session" 2>/dev/null)
    
    if [ -n "$s" ]; then
        export BW_SESSION="$s"
        if bw list folders --session "$s" >/dev/null 2>&1; then
            _fetch_keys
            return 0
        fi
        unset BW_SESSION
    fi

    # 3. Bitwardenの状態チェック
    local bw_status=$(bw status | jq -r .status)
    if [ "$bw_status" = "unauthenticated" ]; then
        echo " ⛔️ Not logged in."
        echo " Run 'bw login' first."
        return 1
    fi

    # 4. ロック解除 (Gum UI - デザイン修正版)
    # --header: 説明文を上に表示
    # --prompt: 入力行の先頭記号
    # --password: 入力文字を隠す
    local mp=$(gum input --password \
        --header "🔐 Unlocking Bitwarden Vault" \
        --placeholder "Master Password" \
        --prompt "🔑 " \
        --width 50)
    
    if [ -z "$mp" ]; then
        echo " ❌ Aborted."
        return 1
    fi

    echo " Unlocking..."
    
    # print -r で記号をそのまま渡す（前回修正済み）
    local ns=$(print -r -- "$mp" | bw unlock --raw 2>/dev/null)

    if [ -n "$ns" ]; then
        export BW_SESSION="$ns"
        security add-generic-password -U -a "$USER" -s "cockpit-bw-session" -w "$ns"
        echo " ✅ Vault Unlocked."
        _fetch_keys
    else
        echo " ❌ Unlock failed."
        return 1
    fi
}

function _fetch_keys() {
    local k=$(bw get password "Gemini API Key" --session "$BW_SESSION" 2>/dev/null)
    [ -z "$k" ] && k=$(bw get password "Cockpit | Gemini API Key" --session "$BW_SESSION" 2>/dev/null)
    
    if [ -n "$k" ]; then 
        export GEMINI_API_KEY="$k"
    else 
        echo " ⚠️ Gemini Key not found in Bitwarden."
        echo "    Run 'sk' (save-key) to save it."
    fi
}

function save-key() {
    local s=$(pbpaste)
    [ -z "$s" ] && echo " 📋 Clipboard is empty." && return 1
    
    local n=$(gum input --header "📦 Save API Key to Bitwarden" --placeholder "Key Name (e.g. OpenAI API Key)" --width 50)
    [ -z "$n" ] && return 1

    [ -z "$BW_SESSION" ] && load_secrets
    [ -z "$BW_SESSION" ] && return 1

    echo " Saving to Bitwarden..."
    print -r -- "$s" | bw encode | bw create item --name "$n" --login-username "apikey" --login-password "$s" --session "$BW_SESSION" > /dev/null
    
    if [ $? -eq 0 ]; then
        echo " ✅ Saved: $n"
        echo "" | pbcopy
    else
        echo " ❌ Save failed."
    fi
}

alias sk="save-key"
