# =================================================================
# 🎮 Cockpit Logic (Zellij & Bitwarden Integrated)
# =================================================================

# --- 1. System Context ---
export DOTFILES="$HOME/dotfiles"
export PATH="$HOME/.nix-profile/bin:$PATH"
setopt +o nomatch
setopt interactivecomments

# --- 2. Safety & Interface ---
alias rm="echo '⛔️ Use \"del\" (trash) or \"/bin/rm\"'; false"
alias del="trash-put"

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

# --- 3. Work Environment (Zellij Cockpit) ---
function work() {
    local n="$1"
    
    # プロジェクト選択
    if [ -z "$1" ]; then
        n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="🚀 Select Project > " --height=50% --layout=reverse)
        if [ -z "$n" ]; then return 1; fi
    fi
    
    local p="$HOME/PARA/1_Projects/$n"
    local r=$(readlink "$p/💻_Code")
    
    if [ -d "$r" ]; then
        echo "🚀 Launching Cockpit for: $n"
        
        # 資産フォルダを開く
        local asset_path=$(readlink "$p/🎨_Assets")
        if [ -d "$asset_path" ]; then open "$asset_path"; fi
        
        # ディレクトリ移動
        cd "$r"
        
        # VS Codeも裏で開いておく
        code .

        # ★ Zellij でコックピットモード起動
        # セッション名はプロジェクト名。レイアウトは 'cockpit'
        eval "zellij --session \"$n\" --layout \"$HOME/dotfiles/config/zellij/layouts/cockpit.kdl\""
    else
        echo "❌ Project code directory not found."
    fi
}

# --- 4. Security Vault (Bitwarden) ---
# .envを使わず、必要な時にメモリにロードする
function load-secrets() {
    if [ -n "$GEMINI_API_KEY" ]; then
        echo "✅ Secrets already loaded in memory."
        return 0
    fi

    echo "🔐 Unlocking Bitwarden Vault..."
    
    # セッションキーがなければログイン/ロック解除
    if [ -z "$BW_SESSION" ]; then
        export BW_SESSION=$(bw unlock --raw)
    fi
    
    if [ -n "$BW_SESSION" ]; then
        echo "🔑 Fetching GEMINI_API_KEY..."
        # 'Gemini' という名前のアイテムからパスワードを取得
        export GEMINI_API_KEY=$(bw get password "Gemini API Key")
        echo "✅ Secrets loaded into memory (Secure)."
    else
        echo "❌ Failed to unlock vault."
    fi
}

# --- 5. AI Wrapper (Auto-Load Secrets) ---
function ask() {
    # キーがなければロードを試みる
    [ -z "$GEMINI_API_KEY" ] && load-secrets

    # それでもなければエラー
    if [ -z "$GEMINI_API_KEY" ]; then echo "❌ API Key missing."; return 1; fi

    local q="$1"
    [ -z "$q" ] && echo "Usage: ask 'question'" && return 1
    
    # ... (既存のAIロジック) ...
    echo "🤖 Asking Gemini..."
    local url="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY"
    local body=$(jq -n --arg q "$q" '{contents: [{parts: [{text: $q}]}]}')
    local result=$(curl -s -X POST -H "Content-Type: application/json" -d "$body" "$url")
    local text=$(echo "$result" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null)
    
    if [ -n "$text" ] && [ "$text" != "null" ]; then
        echo ""; echo "$text" | gum format 2>/dev/null || echo "$text"
    else
        echo "❌ Error."
    fi
}

# --- 6. Definitions ---
alias d="dev"
alias w="work"
alias m="mkproj"
alias f="finish-work"
alias e="edit"
alias a="ask"
alias c="gcm"
alias g="lazygit"
alias zj="zellij"
alias sec="load-secrets"
alias sz="exec zsh"

# --- 7. Loader ---
# 既存の .env は、移行期間中のみ残すが、基本は load-secrets 推奨
[ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"

if [ -d "$DOTFILES/zsh/functions" ]; then
  for f in "$DOTFILES/zsh/functions/"*.zsh; do [ -r "$f" ] && source "$f"; done
fi

# --- 8. Init ---
source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
