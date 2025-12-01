# =================================================================
# 🎮 Cockpit Logic (Live Editable & Auto-Docs)
# =================================================================

# --- 1. System Context ---
export DOTFILES="$HOME/dotfiles"
export PATH="$HOME/.nix-profile/bin:$PATH"
setopt +o nomatch
setopt interactivecomments

# --- 2. Safety First ---
alias rm="echo '⛔️ Use \"del\" (trash) or \"/bin/rm\"'; false"
alias del="trash-put"

# --- 3. Unified Interface ---
function edit() {
    local file="${1:-.}"
    if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
        gum style --foreground 33 "🚀 VS Code: $file"
        code "$file"
    else
        gum style --foreground 150 "⚡ Neovim: $file"
        nvim "$file"
    fi
}

# --- 4. Productivity Boosters ---

## Jump to Project (Contextual Navigation)
function p() {
    local n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="🚀 Jump to > " --height=40% --layout=reverse)
    if [ -n "$n" ]; then
        cd "$HOME/PARA/1_Projects/$n"
        echo "📂 Moved to: $n"
        # 中身をチラ見せ
        if command -v eza >/dev/null; then eza --icons; else ls; fi
    fi
}

## Morning Briefing (Dashboard 2.0)
function briefing() {
    echo ""
    gum style --foreground 214 --bold --border double --padding "0 2" --align center "☀️  MORNING BRIEFING"
    echo ""
    
    # 1. System Health
    gum style --foreground 39 "📉 System Status:"
    if command -v btm >/dev/null; then
        # bottom の簡易表示 (実際は対話型なので、ここではuptimeなどを表示)
        uptime | sed 's/^.*up/Up:/' | sed 's/,.*//' 
        top -l 1 | grep "CPU usage" | awk '{print "CPU: " $3 " user, " $5 " sys"}'
    else
        uptime
    fi
    echo ""

    # 2. Cockpit Status
    gum style --foreground 208 "🐙 Cockpit Git Status:"
    if [ -d "$HOME/dotfiles" ]; then
        git -C "$HOME/dotfiles" status -s
        local branch=$(git -C "$HOME/dotfiles" branch --show-current)
        echo "Branch: $branch"
    fi
    echo ""

    # 3. Active Projects
    gum style --foreground 150 "🔥 Active Projects:"
    ls "$HOME/PARA/1_Projects" 2>/dev/null | head -n 5
    echo ""
    
    gum style --italic "Ready to fly? Type 'd' for dashboard."
    echo ""
}

# --- 5. Auto-Generating Guide ---
function guide() {
    echo ""
    gum style --foreground 214 --bold --border double --padding "0 2" "🧭 COCKPIT HUD (Auto-Generated)"
    echo ""

    local doc_file="$HOME/dotfiles/zsh/cockpit_logic.zsh"
    local menu_items=$(awk '
        /^##/ { 
            sub(/^##[ \t]*/, ""); desc = $0; getline; 
            if ($0 ~ /^alias/) { sub(/^alias /, ""); sub(/=.*/, ""); printf "  %-10s : %s\n", $0, desc; }
            else if ($0 ~ /^function/) { sub(/^function /, ""); sub(/\(\).*/, ""); printf "  %-10s : %s\n", $0, desc; }
        }
    ' "$doc_file")

    echo "🔥 Available Actions:"
    echo "$menu_items"
    echo ""
    gum style --foreground 244 -- "=== Shortcuts ==="
    echo "  del <file> : Safe Delete"
    echo "  Ctrl+R     : History (Atuin)"
    echo "  Tab        : Completion (FZF)"
}

# --- 6. Definitions (Guide Menu) ---

## Morning Briefing
alias b="briefing"

## Dashboard
alias d="dev"

## Jump to Project
alias p="p"

## Work Mode
alias w="work"

## New Project
alias m="mkproj"

## Finish Work
alias f="finish-work"

## Smart Editor
alias e="edit"

## Ask AI
alias a="ask"

## Git Cockpit
alias g="lazygit"

## Workspace
alias zj="zellij"

## Security Check
alias check="audit"

## Archive Project
alias arc="archive"

## Reload
alias sz="exec zsh"

# --- 7. Loader ---
[ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"

if [ -d "$DOTFILES/zsh/functions" ]; then
  for f in "$DOTFILES/zsh/functions/"*.zsh; do
    [ -r "$f" ] && source "$f"
  done
fi

# --- 8. Init ---
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
