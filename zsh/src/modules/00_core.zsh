# --- 00_core.zsh : The Foundation (Enhanced) ---

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

# --- Restored Utilities ---

# 💾 Save Cockpit
function save-cockpit() {
    local dir="$HOME/dotfiles"
    if [ -z "$(git -C "$dir" status --porcelain)" ]; then
        echo "✅ No changes."
        return
    fi
    echo "💾 Saving Cockpit state..."
    git -C "$dir" add .
    git -C "$dir" commit -m "save: $(date '+%Y-%m-%d %H:%M')"
    git -C "$dir" push
    echo "☁️  Saved & Synced!"
}
alias save="save-cockpit"

# 🧹 Clean Garbage
function del() {
    echo "🗑️  Cleaning system garbage..."
    find . -name ".DS_Store" -delete
    # nix-collect-garbage --delete-older-than 7d # 安全のためコメントアウト
    echo "✨ Cleaned."
}

# ❓ Interactive Help
function cockpit-help() {
    echo "🤔 What do you want to do?"
    local selected=$(gum choose --header="🚀 Cockpit Actions" --height=15 \
        "✨ New Project        (m)    | mkproj" \
        "🚀 Start Work         (w)    | work" \
        "📝 Daily Report       (done) | daily" \
        "💾 Save Cockpit       (save) | save-cockpit" \
        "🏥 Health Check       (check)| audit" \
        "🤖 Ask AI             (ask)  | ask")
    [ -z "$selected" ] && return
    local cmd=$(echo "$selected" | awk -F '|' '{print $2}' | xargs)
    echo "Executing: $cmd ..."
    eval "$cmd"
}
alias \?="cockpit-help"
