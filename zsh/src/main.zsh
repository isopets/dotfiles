# =================================================================
# 🎮 Cockpit Logic (Transactional & Self-Healing)
# =================================================================

# --- 1. Core Context (最優先) ---
export DOTFILES="$HOME/dotfiles"
export PATH="$HOME/.nix-profile/bin:$PATH"
setopt +o nomatch
setopt interactivecomments

# --- 2. Vital Functions (これだけは絶対に死守する) ---

# 安全な削除
alias rm="echo '⛔️ Use \"del\" (trash)'; false"
alias del="trash-put"

# エディタ起動 (Unified Interface)
function edit() {
    local file="${1:-.}"
    if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
        gum style --foreground 33 "🚀 VS Code: $file"
        code "$file"
    else
        gum style --foreground 150 "⚡ Neovim: $file"
        nvim "$file"
    fi
}

# リロード (Repair & Reload)
function sz() {
    echo "🔄 Reloading Shell..."
    exec zsh
}

# --- 3. The Smart Loader (安全装置) ---
function source_safe() {
    local file="$1"
    [ ! -f "$file" ] && return

    # A. 構文チェック (Syntax Check)
    if ! zsh -n "$file"; then
        echo "⚠️  Syntax Error detected in: $(basename "$file")"
        echo "🔧 Attempting auto-repair (removing hidden chars)..."
        
        # 自動修復: 不可視文字の削除
        tr -cd '\11\12\40-\176' < "$file" > "${file}.tmp"
        
        # B. 修復後チェック (Verify)
        if zsh -n "${file}.tmp"; then
            mv "${file}.tmp" "$file"
            echo "✅ Repair successful. Loading..."
            source "$file"
        else
            echo "❌ Repair failed. Skipping $(basename "$file") to protect shell."
            rm -f "${file}.tmp"
            return 1
        fi
    else
        # 問題なければ読み込む
        source "$file"
    fi
}

# --- 🔐 Secret Management (Official BW + Keychain) ---
function load_secrets() {
    # 1. 既にメモリにあるなら何もしない
    if [ -n "$GEMINI_API_KEY" ]; then return 0; fi

    # 2. キーチェーンからセッションキーを探す
    #    (securityコマンドはmacOS標準搭載)
    local stored_session=$(security find-generic-password -w -s "cockpit-bw-session" 2>/dev/null)

    # 3. セッションキーが有効かチェック
    if [ -n "$stored_session" ]; then
        export BW_SESSION="$stored_session"
        if bw list folders --session "$BW_SESSION" >/dev/null 2>&1; then
            # 有効ならそのまま進む (サイレント認証)
            _fetch_keys
            return 0
        fi
    fi

    # 4. 無効ならロック解除 (マスターパスワード入力)
    echo "🔐 Unlocking Vault (Official CLI)..."
    # パスワード入力は bw が安全に行う
    local new_session=$(bw unlock --raw)
    
    if [ $? -eq 0 ] && [ -n "$new_session" ]; then
        export BW_SESSION="$new_session"
        echo "✅ Unlocked."
        
        # 5. 新しいセッションをキーチェーンに保存 (上書き)
        security add-generic-password -U -a "$USER" -s "cockpit-bw-session" -w "$BW_SESSION"
        _fetch_keys
    else
        echo "❌ Unlock failed."
        return 1
    fi
}

function _fetch_keys() {
    echo "🔑 Fetching Secrets..."
    # 取得
    export GEMINI_API_KEY=$(bw get password "Gemini API Key" --session "$BW_SESSION")
    
    if [ -n "$GEMINI_API_KEY" ]; then
        echo "✅ Ready."
    else
        echo "⚠️  Gemini API Key not found in Vault."
    fi
}

# --- 4. Load External Modules (Transaction) ---

# Secrets
[ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"

# Functions Loop
if [ -d "$DOTFILES/zsh/functions" ]; then
    for f in "$DOTFILES/zsh/functions/"*.zsh; do
        # 自分自身と utils.zsh (もしあれば) は除外してロード
        if [[ "$(basename "$f")" != "cockpit_logic.zsh" ]]; then
            source_safe "$f"
        fi
    done
fi

# --- 5. The Omni-Command (Integration) ---
# 読み込み後に定義することで、外部関数の有無を確認できる
function c() {
    local subcmd="$1"; shift
    
    # 引数なしならガイド表示
    if [ -z "$subcmd" ]; then 
        if command -v guide >/dev/null; then guide; else echo "🧭 Cockpit Ready (Guide missing)"; fi
        return
    fi

    case "$subcmd" in
        "w"|"work") work "$@" ;;
        "n"|"new")  mkproj "$@" ;;
        "f"|"fin")  finish-work ;;
        "go"|"p")   p ;;
        "e"|"edit") edit "$@" ;;
        "ai"|"ask") ask "$@" ;;
        "ap")       ask-project "$@" ;;
        "l"|"log")  log "$@" ;;
        "g"|"git")  lazygit ;;
        "z"|"zj")   zellij ;;
        "up")       nix-up ;;
        "check")    audit ;;
        "clean")    cleanup ;;
        "fix")      sz ;;
        "b")        briefing ;;
        *) echo "❌ Unknown: c $subcmd" ;;
    esac
}

# --- 6. Aliases & Init ---
alias d="c"
alias w="work"
alias m="mkproj"
alias a="ask"
alias ai="ask"
alias up="nix-up"
alias g="lazygit"
alias z="zoxide"

command -v starship >/dev/null && eval "$(starship init zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
[ -f "$(which navi)" ] && eval "$(navi widget zsh)"
