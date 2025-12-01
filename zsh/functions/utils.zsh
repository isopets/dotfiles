# =================================================================
# 🛠️ Utility Functions (Step 1: Core)
# =================================================================

function _self-clean-files() {
    local func_dir="$HOME/dotfiles/zsh/functions"
    local conf_dir="$HOME/dotfiles/zsh/config"

    # 安全なループ処理
    if [ -d "$func_dir" ]; then
        for f in "$func_dir"/*.zsh; do
            if [ -f "$f" ]; then
                # 不可視文字の削除
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