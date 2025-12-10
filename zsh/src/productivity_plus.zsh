# =================================================================
# 🚀 Cockpit Productivity Plus (v3.2)
# [AI_NOTE]
# 1. undo: Rollback system
# 2. run:  Phoenix Runner (Just + Auto)
# 3. app:  Smart App Installer (Search & Adopt)
# 4. purge: Ghost App Buster
# =================================================================

# --- 1. Time Machine ---
function undo() {
    local gen_path=$(home-manager generations | gum choose --height=10 --header="Select Generation" | awk '{print $7}')
    [ -z "$gen_path" ] && return
    echo "🔄 Rolling back to: $gen_path"
    "$gen_path/activate" && echo "✅ Restored." || echo "❌ Failed."
}

# --- 2. Smart App Installer (Search & Adopt) ---
# [AI_NOTE]
# 1. Brewからアプリを曖昧検索して選択 (Gum)
# 2. 既存のconfigにあるかチェック
# 3. /Applications に手動インストールされた同名アプリがないかチェック
# 4. あればゴミ箱に移動(Adopt)して、Nixに追加・インストール
function app() {
    local query="$1"
    if [ -z "$query" ]; then
        query=$(gum input --placeholder "App Name (fuzzy search)")
    fi
    [ -z "$query" ] && return 1

    echo "🔍 Searching Homebrew Casks..."
    # 検索結果から選択させる
    local selected
    selected=$(brew search --cask "$query" | grep -v "==>" | gum filter --placeholder "Pick the app to install")

    [ -z "$selected" ] && echo "❌ Cancelled." && return 1

    # 重複チェック (Config)
    local config_file="$HOME/dotfiles/nix/modules/darwin.nix"
    if grep -q "\"$selected\"" "$config_file"; then
        echo "⚠️  '$selected' is already in your config."
        return
    fi

    # 衝突チェック (Manual Install)
    # Cask名からアプリ名を完全推測するのは難しいが、brew infoでArtifactの場所を確認できる
    echo "🕵️  Checking for conflicts..."
    local app_info=$(brew info --cask "$selected")
    # Artifact行から .app の名前を抽出 (簡易的)
    local app_name=$(echo "$app_info" | grep -o "[A-Za-z0-9 ]*\.app" | head -n 1)
    
    if [ -n "$app_name" ] && [ -e "/Applications/$app_name" ]; then
        echo "⚠️  Conflict detected: '/Applications/$app_name' already exists."
        
        # Brew管理下かどうか確認
        if brew list --cask "$selected" &>/dev/null; then
             echo "   (It is managed by Homebrew, so it will be adopted automatically.)"
        else
             echo "   (It seems to be installed MANUALLY.)"
             if gum confirm "🗑️  Move existing '$app_name' to Trash to allow Nix installation?"; then
                 echo "🚀 Moving to Trash..."
                 mv "/Applications/$app_name" "$HOME/.Trash/"
             else
                 echo "❌ Cancelled to prevent conflict."
                 return 1
             fi
        fi
    fi

    # 追加処理
    echo "📝 Adding '$selected' to Nix config..."
    if sed --version 2>/dev/null | grep -q GNU; then
        sed -i "/casks =/s/\];/ \"$selected\" \];/" "$config_file"
    else
        sed -i '' "/casks =/s/\];/ \"$selected\" \];/" "$config_file"
    fi

    # インストール実行
    nix-up
}

# --- 3. Universal Runner ---
function run() {
    local cmd=""
    if [ -f "Justfile" ] || [ -f "justfile" ]; then
        [ -n "$1" ] && cmd="just $@" || cmd="just $(just --summary | tr ' ' '\n' | gum choose)"
    elif [ -f "package.json" ] && grep -q '"dev":' package.json; then cmd="npm run dev"
    elif [ -f "main.py" ]; then cmd="python main.py"
    elif [ -f "Cargo.toml" ]; then cmd="cargo run"
    elif [ -f "Makefile" ]; then cmd="make"
    else echo "🤔 No runnable config. Run 'mkjust'."; return; fi
    
    [ -z "$cmd" ] && return
    echo "🚀 Executing: $cmd"
    eval "$cmd" || {
        echo "💥 Failed."
        gum confirm "🔥 Ask AI to fix?" && ask "Fix this command error:\nCmd: $cmd"
    }
}

# --- 4. MKJust & Explain ---
function mkjust() {
    [ -f "Justfile" ] && echo "⚠️ Exists." && return
    ask "Create Justfile for this project structure:\n$(ls -F)" > Justfile && echo "✨ Created."
}
function explain() { ask "Explain command:\n$*"; }
function purge() {
    local g=$(brew bundle cleanup --file=~/dotfiles/nix/modules/darwin.nix --global 2>/dev/null)
    [ -z "$g" ] && echo "✨ Clean." && return
    echo "⚠️  Ghosts:\n$g"
    gum confirm "🔥 Burn?" && brew bundle cleanup --force --file=~/dotfiles/nix/modules/darwin.nix --global
}

# Aliases
alias start="run"
alias rollback="undo"
alias wtf="explain"
