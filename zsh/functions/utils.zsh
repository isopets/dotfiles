# =================================================================
# 🛠️ Utility Functions (Minimal Repair Version)
# =================================================================

function sz() {
    echo "🔄 Reloading Shell..."
    exec zsh
}

function rules() {
    code "$HOME/dotfiles/docs/WORKFLOW.md"
}

function dot-doctor() {
    echo "🚑 System Check..."
    command -v fzf >/dev/null && echo "✅ fzf" || echo "❌ fzf"
}

function guide() {
    echo "🧭 GUIDE: Run 'sz' to reload, then 'nix-up' to sync."
}

function brain() {
    echo "🧠 Brain module is temporarily disabled for repair."
}
