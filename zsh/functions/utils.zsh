# utils.zsh の最終安定版
function _self-clean-files() {
    local functions_dir="$HOME/dotfiles/zsh/functions"
    local config_dir="$HOME/dotfiles/zsh/config"
    for f in "$functions_dir"/*.zsh "$config_dir"/*.zsh; do
        [ -f "$f" ] && tr -cd '\11\12\40-\176' < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    done
}

function sz() {
    _self-clean-files
    echo "🔄 Re-spawning Shell Process..."
    exec zsh
}

function rules() { code ~/dotfiles/docs/WORKFLOW.md; }

function dot-doctor() {
    local health=100
    if command -v fzf >/dev/null; then echo "  ✅ fzf found"; else echo "  ❌ fzf missing"; health=50; fi
    if command -v code >/dev/null; then echo "  ✅ code found"; else echo "  ❌ code missing"; health=50; fi
    if [ $health -eq 100 ]; then echo "✨ System Healthy."; else echo "⚠️ System Check Failed."; fi
}

function brain() {
    local brain_dir="$HOME/PARA/0_Inbox/Brain"
    mkdir -p "$brain_dir"

    if [ "$1" = "new" ]; then
        echo -n "🧠 Note Title: "; read title
        local safe_title=$(echo "$title" | tr ' ' '_')
        local file="$brain_dir/$(date +%Y%m%d)_${safe_title}.md"
        echo "# $title\n\n" > "$file"
        code "$file"
        return
    fi

    local selected=$(grep -r "" "$brain_dir" 2>/dev/null | \
        fzf --delimiter : --with-nth 1,3 --preview 'bat --style=numbers --color=always {1} --highlight-line {2}' \
            --preview-window 'right:60%' \
            --prompt="🧠 Search Brain > " \
            --bind 'enter:execute(code {1})')
}