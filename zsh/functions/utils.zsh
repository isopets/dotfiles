function ali() { local s=$(alias|fzf|cut -d'='-f1); [ -n "$s" ] && print -z "$s"; }
function myhelp() { cat ~/dotfiles/zsh/functions/*.zsh | bat -l bash --style=plain; }
function dot-doctor() {
    echo "🚑 Check..."; local ec=0
    for t in git zoxide eza bat lazygit fzf direnv starship mise bw; do if command -v "$t" &> /dev/null; then echo "✅ $t"; else echo "❌ $t missing"; ((ec++)); fi; done
    unlock-bw && echo "✅ Bitwarden" || echo "❌ Bitwarden Locked"
    echo "🔥 Issues: $ec"
}
function show-tip() {
    local tips=("💡 z:爆速移動" "💡 work:コックピット" "💡 dev:メニュー" "💡 save-key:キー保存" "💡 why:Q&A")
    echo "${tips[$RANDOM % ${#tips[@]}]}"
}
function why() {
    local qf="$HOME/dotfiles/docs/QA.md"
    local q=$(grep "^## Q:" "$qf" | sed 's/^## Q: //')
    local s=$(echo "$q" | fzf --prompt="🤔 Why? > ")
    [ -n "$s" ] && awk -v q="$s" '/^## Q:/ {f=0} $0 ~ q {f=1; next} f {print}' "$qf" | sed '/^$/d'
}
