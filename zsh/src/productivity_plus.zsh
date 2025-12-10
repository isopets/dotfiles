# =================================================================
# 🚀 Cockpit Productivity Plus Module (Autonomous Edition)
# [AI_NOTE]
# 1. undo: Time Machine
# 2. run:  Phoenix Protocol (Auto-Healing) 搭載ランナー
# 3. mkjust: AI Architect
# 4. recon: Active Reconnaissance (ディレクトリ移動時に自動発動)
# =================================================================

# --- 1. Time Machine (Nix Rollback) ---
function undo() {
    echo "🕰️  Time Machine: Select a generation to restore..."
    local gen_path
    gen_path=$(home-manager generations | gum choose --height=10 --header="Select Generation to Restore" | awk '{print $7}')
    if [ -z "$gen_path" ]; then echo "❌ Cancelled."; return 1; fi
    echo "🔄 Rolling back to: $gen_path"
    "$gen_path/activate" && echo "✅ Restored. Please restart shell." || echo "❌ Failed."
}

# --- 2. Universal Runner (with Phoenix Protocol) ---
function run() {
    local cmd=""
    local cmd_str=""

    # --- A. Command Selection ---
    if [ -f "Justfile" ] || [ -f "justfile" ]; then
        if [ -n "$1" ]; then
            cmd="just $@"
            cmd_str="just $*"
        else
            local selected
            selected=$(just --summary | tr ' ' '\n' | gum choose --height=10 --header="🚀 Just Runner")
            [ -z "$selected" ] && echo "❌ Cancelled." && return
            cmd="just $selected"
            cmd_str="just $selected"
        fi
    elif [ -f "package.json" ] && grep -q '"dev":' package.json; then
        cmd="npm run dev"; cmd_str="npm run dev"
    elif [ -f "main.py" ]; then
        cmd="python main.py"; cmd_str="python main.py"
    elif [ -f "Cargo.toml" ]; then
        cmd="cargo run"; cmd_str="cargo run"
    elif [ -f "Makefile" ]; then
        cmd="make"; cmd_str="make"
    else
        echo "🤔 No runnable configuration."
        echo "💡 Tip: Run 'mkjust' to generate one."
        return
    fi

    # --- B. Execution & Phoenix Protocol ---
    echo "🚀 Executing: $cmd_str"
    
    # 実行し、エラーならログを一時ファイルに保存
    local log_tmp=$(mktemp)
    eval "$cmd" 2>&1 | tee "$log_tmp"
    local exit_code=${PIPESTATUS[0]} # パイプの前の終了コードを取得

    # --- C. Error Recovery ---
    if [ $exit_code -ne 0 ]; then
        echo ""
        echo "💥 Mission Failed (Exit Code: $exit_code)"
        
        # Gumが使える場合のみ、インタラクティブに復旧を提案
        if command -v gum >/dev/null; then
            if gum confirm "🔥 Phoenix Protocol: Ask AI to analyze this error?"; then
                echo "🚑 Analyzing error log..."
                local error_tail=$(tail -n 20 "$log_tmp")
                local prompt="以下のコマンド実行時にエラーが発生しました。原因と修正方法を簡潔に教えてください。\n\nコマンド: \`$cmd_str\`\n\n--- エラーログ ---\n$error_tail"
                
                # ai.zsh の ask 関数を呼び出す
                ask "$prompt"
            fi
        fi
    fi
    rm "$log_tmp"
}

# --- 3. AI Justfile Generator ---
function mkjust() {
    if [ -f "Justfile" ]; then echo "⚠️ Justfile exists."; return 1; fi
    echo "🤖 Analyzing project structure..."
    local files=""; if command -v eza >/dev/null; then files=$(eza --tree --level=2 -I ".git|node_modules|.DS_Store"); else files=$(find . -maxdepth 2 -not -path '*/.*'); fi
    local hints=""; [ -f "package.json" ] && hints+="\n--- package.json ---\n$(cat package.json | head -n 20)"

    echo "⚡ Asking Gemini..."
    local prompt="DevOpsの専門家として、このプロジェクトに最適な 'Justfile' を作成してください。\n要件: dev, build, test 等のタスクを含める。推測で書く。出力はファイルの中身のみ。\n\nFiles:\n$files\n\nHints:\n$hints"
    
    local content=$(ask "$prompt")
    if [ -n "$content" ]; then
        echo "$content" > Justfile
        echo "✨ Justfile generated! Type 'run' to start."
    else
        echo "❌ AI failed."
    fi
}

# --- 4. Active Reconnaissance (Hook) ---
# [AI_NOTE] ディレクトリ移動(chpwd)のたびに実行される偵察関数。
# Justfileがある場合、利用可能なレシピを薄く表示してユーザーに知らせる。
function _cockpit_recon() {
    if [ -f "Justfile" ] || [ -f "justfile" ]; then
        # レシピ一覧を横並びで取得
        local recipes=$(just --summary)
        # グレー色で控えめに表示 (Gum style or ANSI escape)
        echo -e "\033[1;30m💡 Available: $recipes\033[0m"
    fi
}

# Zshのフックに登録 (重複登録防止)
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _cockpit_recon

# --- 5. AI Explainer ---
function explain() {
    local cmd="$*"
    [ -z "$cmd" ] && echo "Usage: explain 'cmd'" && return 1
    ask "以下のコマンドの目的とリスクを日本語で解説:\n\`$cmd\`"
}

# Aliases
alias start="run"
alias rollback="undo"
alias wtf="explain"

# --- 5. Ghost App Buster ---
# [AI_NOTE] Nix/Homebrewの管理外にある「幽霊アプリ」を検知し、
# インタラクティブに削除する掃除屋。
function purge() {
    echo "👻 Hunting for Ghost Apps (Unmanaged Applications)..."
    
    # Check 1: Brewfileとの乖離を確認
    # (darwin.nixの設定に基づいて、消すべきものをリストアップ)
    local ghosts
    ghosts=$(brew bundle cleanup --file=~/dotfiles/nix/modules/darwin.nix --global 2>/dev/null)

    if [ -z "$ghosts" ]; then
        echo "✨ System is clean! No ghost apps found."
        return
    fi

    echo "⚠️  Found unmanaged apps:"
    echo "$ghosts"
    echo ""

    if gum confirm "🔥 Burn them all? (Uninstall)"; then
        echo "🚀 Purging..."
        # 実際に削除を実行 (Force clean)
        # Note: nix-darwinのzap設定に依存するが、ここで明示的に呼ぶことで即時性を高める
        brew bundle cleanup --force --file=~/dotfiles/nix/modules/darwin.nix --global
        
        echo "✅ Purge complete. System is now consistent."
    else
        echo "🛡️  Operation cancelled."
    fi
}
