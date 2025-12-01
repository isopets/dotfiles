# =================================================================
# 🛠️ Utility Functions (Clean)
# =================================================================

function _self-clean-files() {
    local target_dirs=("$HOME/dotfiles/zsh/functions" "$HOME/dotfiles/zsh/config")
    for d in "${target_dirs[@]}"; do
        if [ -d "$d" ]; then
            for f in "$d"/*.zsh; do
                [ -f "$f" ] && tr -cd '\11\12\40-\176' < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
            done
        fi
    done
}

function sz() {
    echo "🧹 Cleaning environment..."
    _self-clean-files
    echo "🔄 Reloading Shell..."
    exec zsh
}

function rules() {
    code "$HOME/dotfiles/docs/WORKFLOW.md"
}

function dot-doctor() {
    echo "🚑 Cockpit Diagnosis..."
    command -v fzf >/dev/null && echo "✅ fzf found" || echo "❌ fzf missing"
    command -v code >/dev/null && echo "✅ code found" || echo "❌ code missing"
}

function brain() {
    local dir="$HOME/PARA/0_Inbox/Brain"
    mkdir -p "$dir"
    if [ "$1" = "new" ]; then
        echo -n "🧠 Title: "; read t
        local safe_t=$(echo "$t" | tr ' ' '_')
        code "$dir/$(date +%Y%m%d)_${safe_t}.md"
    else
        grep -r "" "$dir" 2>/dev/null | fzf --delimiter : --with-nth 1,3 --bind 'enter:execute(code {1})'
    fi
}