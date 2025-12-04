# System Context
export DOTFILES="$HOME/dotfiles"
export PATH="$HOME/.nix-profile/bin:$PATH"
setopt +o nomatch
setopt interactivecomments

# Safety First
alias rm="echo '⛔️ Use \"del\" (trash)'; false"
alias del="trash-put"

# Unified Interface (Edit)
function edit() {
    local file="${1:-.}"
    if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
        gum style --foreground 33 "🚀 VS Code: $file"; code "$file"
    else
        gum style --foreground 150 "⚡ Neovim: $file"; nvim "$file"
    fi
}

# Reload & Repair
function sz() {
    echo "🧹 Cleaning environment..."
    for f in "$HOME/dotfiles/zsh/functions/"*.zsh; do
        [ -f "$f" ] && tr -cd '\11\12\40-\176' < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    done
    echo "🔄 Reloading Shell..."
    exec zsh
}

# Omni-Command (Entry Point)
function c() {
    local subcmd="$1"; shift
    if [ -z "$subcmd" ]; then guide; return; fi
    case "$subcmd" in
        "w"|"work") work "$@" ;;
        "n"|"new")  mkproj "$@" ;;
        "f"|"fin")  finish-work ;;
        "go"|"p")   p ;;
        "e"|"edit") edit "$@" ;;
        "ai"|"ask") ask "$@" ;;
        "ap")       ask-project "$@" ;;
        "l"|"log")  log "$@" ;;
        "g"|"git")  lazygit ;;
        "z"|"zj")   zellij ;;
        "up")       nix-up ;;
        "check")    audit ;;
        "clean")    cleanup ;;
        "fix")      sz ;;
        "b")        briefing ;;
        "sk")       save-key ;;
        "dump")     dump-context ;;
        *) echo "❌ Unknown: c $subcmd" ;;
    esac
}

# Basic Aliases
alias d="c"
alias e="edit"
alias sz="exec zsh"
