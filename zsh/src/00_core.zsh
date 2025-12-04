# System Context
export DOTFILES="$HOME/dotfiles"
export PATH="$HOME/.nix-profile/bin:$PATH"
setopt +o nomatch
setopt interactivecomments

# --- Safety ---
## Safe Delete
alias rm="echo '⛔️ Use \"del\" (trash)'; false"
alias del="trash-put"

# --- Core Functions ---

## Smart Editor
function edit() {
    local file="${1:-.}"
    if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
        gum style --foreground 33 "🚀 VS Code: $file"; code "$file"
    else
        gum style --foreground 150 "⚡ Neovim: $file"; nvim "$file"
    fi
}

## Reload Shell
function sz() {
    echo "🧹 Cleaning environment..."
    for f in "$HOME/dotfiles/zsh/src/"*.zsh; do
        [ -f "$f" ] && tr -cd '\11\12\40-\176' < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    done
    echo "🔄 Reloading Shell..."
    exec zsh
}

# --- The Omni-Command ---
## Dashboard
function c() {
    # 🚨 修正: 引数がない場合は即ガイドを表示して終了
    if [ $# -eq 0 ]; then
        guide
        return
    fi

    local subcmd="$1"; shift
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
