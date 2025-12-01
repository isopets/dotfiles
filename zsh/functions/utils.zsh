function _self-clean-files() {
    # 隠し文字削除の対象ディレクトリ
    local func_dir="$HOME/dotfiles/zsh/functions"
    local conf_dir="$HOME/dotfiles/zsh/config"

    # ファイルが存在するか確認してから処理
    if [ -d "$func_dir" ]; then
        for f in "$func_dir"/*.zsh; do
            if [ -f "$f" ]; then
                tr -cd '\11\12\40-\176' < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
            fi
        done
    fi

    if [ -d "$conf_dir" ]; then
        for f in "$conf_dir"/*.zsh; do
            if [ -f "$f" ]; then
                tr -cd '\11\12\40-\176' < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
            fi
        done
    fi
}

function sz() {
    echo "🧹 Running integrity check..."
    _self-clean-files
    echo "🔄 Reloading Shell..."
    exec zsh
}

function rules() {
    code "$HOME/dotfiles/docs/WORKFLOW.md"
}

function dot-doctor() {
    echo "🚑 Cockpit Diagnosis..."
    if command -v fzf >/dev/null; then
        echo "✅ fzf found"
    else
        echo "❌ fzf missing"
    fi
}

function guide() {
    echo ""
    gum style --foreground 214 --bold --border double --padding "0 2" "🧭 COCKPIT HUD"
    echo ""
    
    # 意図的にシンプルなif文を使用
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        gum style --foreground 196 "🔥 Project Mode"
    else
        gum style --foreground 39 "🌍 Global Mode"
    fi
    
    echo ""
    echo "  🔄 sz / 🕰️ nix-history / 🧠 brain"
}

function brain() {
    local dir="$HOME/PARA/0_Inbox/Brain"
    mkdir -p "$dir"
    
    if [ "$1" = "new" ]; then
        echo -n "🧠 Title: "
        read t
        local safe_t=$(echo "$t" | tr ' ' '_')
        code "$dir/$(date +%Y%m%d)_${safe_t}.md"
    else
        grep -r "" "$dir" 2>/dev/null | fzf --delimiter : --with-nth 1,3 --bind 'enter:execute(code {1})'
    fi
}