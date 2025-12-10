# =================================================================
# 🚀 Cockpit Productivity Plus (v3.3 Smart Adoption)
# [AI_NOTE]
# 1. app: 手動アプリを検知し、安全にNix管理下へ移行させる (Adoption)
# 2. run: 万能ランナー
# 3. undo: タイムマシン
# =================================================================

# --- 1. Smart App Installer (Adoption Edition) ---
function app() {
    local query="$1"
    if [ -z "$query" ]; then
        query=$(gum input --placeholder "App Name (fuzzy search)")
    fi
    [ -z "$query" ] && return 1

    echo "🔍 Searching Homebrew Casks..."
    # 検索結果から選択 (インストール済みかどうかも表示したいが、まずはシンプルに検索)
    local selected
    selected=$(brew search --cask "$query" | grep -v "==>" | gum filter --placeholder "Pick the app to install")
    [ -z "$selected" ] && echo "❌ Cancelled." && return 1

    # 重複チェック (Config内)
    local config_file="$HOME/dotfiles/nix/modules/darwin.nix"
    if grep -q "\"$selected\"" "$config_file"; then
        echo "⚠️  '$selected' is already in your nix config."
        echo "   (If it's broken, try running 'up' again to repair links.)"
        return
    fi

    # 🕵️ 衝突検知 & 養子縁組 (Adoption) ロジック
    echo "🕵️  Checking installation status..."
    
    # brew info から正式な .app 名を取得 (Artifact)
    local app_info=$(brew info --cask "$selected")
    local app_name=$(echo "$app_info" | grep -o "[A-Za-z0-9 ]*\.app" | head -n 1 | awk '{$1=$1};1') # trim
    local app_path="/Applications/$app_name"

    if [ -n "$app_name" ] && [ -e "$app_path" ]; then
        echo "---------------------------------------------------"
        echo "⚠️  COLLISION DETECTED: '$app_name' exists."
        echo "📂 Location: $app_path"
        
        # シンボリックリンク判定 (これが重要！)
        if [ -L "$app_path" ]; then
             echo "🔗 Type: Symlink (Managed by Homebrew/Nix)"
             echo "✅ Safe to proceed. (Just adding to config)"
        else
             echo "📁 Type: Real Directory (Likely Manual Install)"
             echo "🚨 This will conflict with Nix installation."
        fi
        echo "---------------------------------------------------"

        # ユーザーに判断を委ねる
        echo "🤖 Proposal: Adopt '$app_name' into Cockpit (Nix)?"
        echo "   [Action] 1. Move current app to Trash"
        echo "            2. Add to darwin.nix"
        echo "            3. Install via Nix (Clean Install)"
        
        if gum confirm "🚀 Do you want to Adopt this app?"; then
            echo "🗑️  Moving '$app_path' to Trash..."
            mv "$app_path" "$HOME/.Trash/"
        else
            echo "❌ Cancelled. Keeping manual installation."
            return 1
        fi
    else
        echo "✅ No conflict found. Proceeding with fresh install."
    fi

    # 設定ファイルへの追記
    echo "📝 Adding '$selected' to Nix config..."
    if sed --version 2>/dev/null | grep -q GNU; then
        sed -i "/casks =/s/\];/ \"$selected\" \];/" "$config_file"
    else
        sed -i '' "/casks =/s/\];/ \"$selected\" \];/" "$config_file"
    fi

    # インストール実行
    echo "🚀 Installing via Nix..."
    nix-up
}

# --- 2. Universal Runner ---
function run() {
    local cmd=""
    if [ -f "Justfile" ] || [ -f "justfile" ]; then
        [ -n "$1" ] && cmd="just $@" || cmd="just $(just --summary | tr ' ' '\n' | gum choose)"
    elif [ -f "package.json" ] && grep -q '"dev":' package.json; then cmd="npm run dev"
    elif [ -f "main.py" ]; then cmd="python main.py"
    elif [ -f "Cargo.toml" ]; then cmd="cargo run"
    elif [ -f "Makefile" ]; then cmd="make"
    else echo "🤔 No runnable config."; return; fi
    
    [ -z "$cmd" ] && return
    echo "🚀 Executing: $cmd"
    eval "$cmd" || {
        echo "💥 Failed."
        gum confirm "🔥 Ask AI to fix?" && ask "Fix this command error:\nCmd: $cmd"
    }
}

# --- 3. Utilities ---
function mkjust() { [ -f "Justfile" ] && return; ask "Create Justfile for:\n$(ls -F)" > Justfile; }
function undo() { local g=$(home-manager generations|gum choose|awk '{print $7}'); [ -n "$g" ] && "$g/activate"; }
function explain() { ask "Explain command:\n$*"; }
function purge() { 
    local g=$(brew bundle cleanup --file=~/dotfiles/nix/modules/darwin.nix --global 2>/dev/null)
    [ -z "$g" ] && echo "✨ Clean." && return
    echo "⚠️  Ghosts:\n$g"; gum confirm "🔥 Burn?" && brew bundle cleanup --force --file=~/dotfiles/nix/modules/darwin.nix --global
}

# Aliases
alias start="run"
alias rollback="undo"
alias wtf="explain"
