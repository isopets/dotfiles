# =================================================================
# 🧠 Cockpit Core Logic (Restored)
# =================================================================

# --- 🔄 Reload Shell ---
alias sz="source ~/.zshrc && echo '✅ Zsh config reloaded!'"

# --- 🛠️ Utility Aliases ---
alias conf="code ~/dotfiles"
alias code-config="code ~/dotfiles"
alias ll="ls -lF"
alias la="ls -laF"
alias ..="cd .."

# --- 🧠 Context Dump ---
alias dump-cockpit="~/dotfiles/scripts/dump_context.sh"

## 🏗️ Project Manager (mkproj)
function mkproj() {
    local name="$1"
    [ -z "$name" ] && name=$(gum input --placeholder "Project Name")
    [ -z "$name" ] && return 1

    local p="$HOME/PARA/1_Projects/$name"
    if [ -d "$p" ]; then
        echo "⚠️  Project '$name' already exists."
        return 1
    fi

    echo "🏗️  Creating Project: $name"
    mkdir -p "$p/_Code" "$p/_Docs" "$p/_Assets"
    echo "# $name" > "$p/_Docs/README.md"
    git init "$p/_Code" >/dev/null

    echo "✅ Project created at $p"
    if gum confirm "Open in VS Code?"; then
        code "$p/_Code"
    fi
}

## 📝 Daily Report (daily)
function daily() {
    local today=$(date +%Y-%m-%d)
    local dir="$HOME/PARA/0_Inbox/Daily"
    mkdir -p "$dir"
    local file="$dir/${today}.md"
    
    if [ ! -f "$file" ]; then
        echo "# Daily Report: $today" > "$file"
        echo "" >> "$file"
        echo "## 🎯 Focus" >> "$file"
        echo "" >> "$file"
        echo "## 📝 Log" >> "$file"
    fi
    code "$file"
}

## 🔄 Sync Configs (sync-config)
function sync-config() {
    echo "🔄 Syncing configurations..."
    mkdir -p ~/.config
    [ -d "$HOME/dotfiles/config/karabiner" ] && ln -sfn "$HOME/dotfiles/config/karabiner" ~/.config/karabiner
    [ -d "$HOME/dotfiles/config/zellij" ] && ln -sfn "$HOME/dotfiles/config/zellij" ~/.config/zellij
    [ -f "$HOME/.config/starship.toml" ] || ln -sfn "$HOME/dotfiles/config/starship.toml" ~/.config/starship.toml
    echo "✅ Sync complete."
}

## 🧹 Clean Garbage (del)
function del() {
    echo "🗑️  Cleaning system garbage..."
    find . -name ".DS_Store" -delete
    nix-collect-garbage --delete-older-than 7d
    echo "✨ Cleaned."
}

## 🏥 Health Check (audit)
function audit() {
    echo "🏥 Starting Health Check..."
    echo "---------------------------"
    echo -n "Checking Nix... "
    if command -v nix >/dev/null; then echo "✅ OK"; else echo "❌ Missing"; fi
    echo -n "Checking Starship... "
    if command -v starship >/dev/null; then echo "✅ OK"; else echo "❌ Missing"; fi
    echo -n "Checking Zoxide... "
    if command -v zoxide >/dev/null; then echo "✅ OK"; else echo "❌ Missing"; fi
    echo "---------------------------"
    echo "Done."
}

## 🤖 Ask AI (ask)
function ask() {
    if command -v gh >/dev/null; then
        eval "$(gh copilot suggest -t shell "$*" --shell zsh)"
    else
        echo "❌ GitHub CLI (gh) not found. Run 'nix-add gh' first."
    fi
}

## ❓ Interactive Help
function cockpit-help() {
    echo "🤔 What do you want to do?"
    local selected=$(gum choose --header="🚀 Cockpit Actions" --height=20 \
        "✨ New Project        (m)    | mkproj" \
        "🚀 Start Work         (w)    | work" \
        "📝 Daily Report       (done) | daily" \
        "💾 Save Cockpit       (save) | save-cockpit" \
        "🔄 Sync Settings      (sync) | sync-config" \
        "📦 Install App        (app)  | app" \
        "⬆️  Update System      (up)   | nix-up" \
        "🏥 Health Check       (check)| audit" \
        "🧹 Clean Garbage      (del)  | del" \
        "🤖 Ask AI             (ask)  | ask")
    [ -z "$selected" ] && return
    local cmd=$(echo "$selected" | awk -F '|' '{print $2}' | xargs)
    echo "Executing: $cmd ..."
    eval "$cmd"
}
alias \?="cockpit-help"

## 💾 Save Cockpit
function save-cockpit() {
    local dir="$HOME/dotfiles"
    if [ -z "$(git -C "$dir" status --porcelain)" ]; then
        echo "✅ No changes."
        return
    fi
    git -C "$dir" add .
    git -C "$dir" commit -m "save: $(date '+%Y-%m-%d %H:%M')"
    git -C "$dir" push
    echo "☁️  Saved!"
}
alias save="save-cockpit"

# --- 🚀 Cockpit Boosters ---
if command -v zoxide >/dev/null; then
    eval "$(zoxide init zsh)"
    alias cd="z" 
fi
if command -v starship >/dev/null; then
    eval "$(starship init zsh)"
fi
if command -v lazygit >/dev/null; then
    alias lg="lazygit"
fi
