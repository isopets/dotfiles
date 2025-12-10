# =================================================================
# 🚀 Cockpit Productivity Plus (v4.0 Async Edition)
# [AI_NOTE]
# "Fire and Forget" 思想の実装。
# ユーザーを待たせない。認証さえ通れば、あとは裏のタブ(Zellij)で執事がやる。
# =================================================================

# --- 1. Async App Installer ---
function app() {
    local query="$1"
    
    # 1. 検索・選択フェーズ (ここは対話が必要なので待つ)
    if [ -z "$query" ]; then query=$(gum input --placeholder "App Name"); fi
    [ -z "$query" ] && return
    
    local selected
    selected=$(brew search --cask "$query" | grep -v "==>" | gum filter --placeholder "Select App")
    [ -z "$selected" ] && return

    # 2. 設定ファイルへの追記 (一瞬で終わる)
    local config_file="$HOME/dotfiles/nix/modules/darwin.nix"
    if grep -q "\"$selected\"" "$config_file"; then
        echo "⚠️  Already in config. Re-installing..."
    else
        if sed --version 2>/dev/null | grep -q GNU; then
            sed -i "/casks =/s/\];/ \"$selected\" \];/" "$config_file"
        else
            sed -i '' "/casks =/s/\];/ \"$selected\" \];/" "$config_file"
        fi
        echo "📝 Added '$selected' to config."
    fi

    # 3. インストール実行 (非同期化)
    echo "🚀 Dispatching background installer..."

    # 新しいタブを作り、そこで認証 -> 実行 -> 自動クローズを行う
    # (ユーザーの今の画面はブロックされない！)
    local job_name="📦 Installing $selected"
    
    zellij action new-tab --name "$job_name" --cwd "$HOME" -- zsh -c "
        echo '🔑 Auth Required for Install...';
        echo '--------------------------------';
        sudo -v; 
        if sudo ~/dotfiles/scripts/cockpit-update.sh; then
            osascript -e 'display notification \"Installed: $selected 🚀\" with title \"Cockpit\"';
            echo '✅ Done. Closing...';
            sleep 3;
            zellij action close-tab;
        else
            echo '❌ Failed.';
            osascript -e 'display notification \"Install Failed: $selected ⚠️\" with title \"Cockpit\"';
            echo 'Press Enter to inspect logs...';
            read;
        fi
    "
    
    echo "✅ Job started in background tab. You can keep working!"
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
