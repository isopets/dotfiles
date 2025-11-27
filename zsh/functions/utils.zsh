function ali() { local s=$(alias|fzf|cut -d'='-f1); [ -n "$s" ] && print -z "$s"; }
function myhelp() { cat ~/dotfiles/zsh/functions/*.zsh | bat -l bash --style=plain; }
function dot-doctor() {
    echo "🚑 Check..."; local ec=0
    for t in git zoxide eza bat lazygit fzf direnv starship mise bw; do if command -v "$t" &> /dev/null; then echo "✅ $t"; else echo "❌ $t missing"; ((ec++)); fi; done
    if [ -n "$GEMINI_API_KEY" ]; then echo "✅ AI Key"; else echo "❌ AI Key"; ((ec++)); fi
    echo "🔥 Issues: $ec"
}
function show-tip() {
    local tips=("💡 z:Jump" "💡 work:Cockpit" "💡 mkproj:New" "💡 dev:Menu" "💡 save-key:Save" "💡 why:Q&A" "💡 f:File")
    echo "${tips[$RANDOM % ${#tips[@]}]}"
}
function why() {
    local qf="$HOME/dotfiles/docs/QA.md"
    local q=$(grep "^## Q:" "$qf" | sed 's/^## Q: //')
    local s=$(echo "$q" | fzf --prompt="🤔 Why? > ")
    [ -n "$s" ] && awk -v q="$s" '/^## Q:/ {f=0} $0 ~ q {f=1; next} f {print}' "$qf" | sed '/^$/d'
}
function f() {
    local file=$(fd --type f --hidden --exclude .git | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}')
    [ -n "$file" ] && code "$file"
}
function save-dot() {
    echo "📦 Saving Dotfiles..."
    git -C ~/dotfiles add .
    local msg="chore: Update settings $(date)"
    # AIメッセージ生成は省略して堅牢性優先
    git -C ~/dotfiles commit -m "$msg"
    git -C ~/dotfiles push
    echo "✅ Done."
}
