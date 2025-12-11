# --- 00_core.zsh : The Foundation (Auto-Deploy Edition) ---

# Context Launcher
function copen() {
    setopt local_options nullglob; local t="${1:-.}"; local d="$t"
    [ -f "$t" ] && d=$(dirname "$t")
    local p="[Base] Common"
    if [ -f "$d/.cockpit_profile" ]; then p=$(cat "$d/.cockpit_profile")
    elif [ -n "$(ls "$d"/*.py 2>/dev/null)" ]; then p="[Lang] Python"
    elif [ -f "$d/package.json" ]; then p="[Lang] Web"
    fi
    echo "🚀 Launching: $p"; command code --profile "$p" "$t"
}

# Helpers
function ask() {
    [ -f "$HOME/dotfiles/scripts/ask_ai.py" ] && python3 "$HOME/dotfiles/scripts/ask_ai.py" "$*" || echo "AI Offline"
}
function nix-up() {
    [ -f "$HOME/dotfiles/scripts/cockpit-update.sh" ] && sudo "$HOME/dotfiles/scripts/cockpit-update.sh"
}
function load_secrets() {
    [ -n "$GEMINI_API_KEY" ] && return
    local k=$(gum input --password --placeholder "Gemini Key")
    [ -n "$k" ] && export GEMINI_API_KEY="$k" && echo "✅ Loaded"
}
alias sk="load_secrets"

# --- 🚀 Smart Save & Deploy System ---
function save-cockpit() {
    local dir="$HOME/dotfiles"
    local msg="$1"

    # 1. 変更チェック
    if [ -z "$(git -C "$dir" status --porcelain)" ]; then
        echo "✅ No changes to save."
        return
    fi

    # 2. メッセージ入力
    if [ -z "$msg" ]; then
        msg=$(gum input --placeholder "Commit Message")
    fi
    [ -z "$msg" ] && msg="Update: $(date '+%Y-%m-%d %H:%M')"

    echo "💾 Saving to develop..."
    git -C "$dir" add .
    git -C "$dir" commit -m "$msg"
    git -C "$dir" push origin develop

    # 3. Mainへの自動マージ
    echo ""
    if gum confirm "🚀 Release to Main?"; then
        echo "⚡️ Deploying..."
        git -C "$dir" checkout main
        git -C "$dir" merge develop
        git -C "$dir" push origin main
        git -C "$dir" checkout develop
        echo "✅ All Synced!"
    else
        echo "👍 Saved to develop."
    fi
}
alias save="save-cockpit"
alias ship="save-cockpit"

# 🧹 Clean Garbage
function del() {
    echo "🗑️  Cleaning..."
    find . -name ".DS_Store" -delete
    echo "✨ Cleaned."
}

# ❓ Help
function cockpit-help() {
    local s=$(gum choose "✨ New Project" "🚀 Start Work" "💾 Save & Ship" "📝 Daily Report" "🏥 Health Check" "🤖 Ask AI")
    [ -z "$s" ] && return
    case "$s" in
        *"New"*) mkproj ;;
        *"Start"*) work ;;
        *"Save"*) save-cockpit ;;
        *"Daily"*) daily ;;
        *"Health"*) audit ;;
        *"Ask"*) ask ;;
    esac
}
alias \?="cockpit-help"