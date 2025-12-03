export DOTFILES="$HOME/dotfiles"
export PATH="$HOME/.nix-profile/bin:$PATH"
setopt +o nomatch
setopt interactivecomments

alias rm="echo '⛔️ Use \"del\" (trash) or \"/bin/rm\"'; false"
alias del="trash-put"

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

function c() {
    local subcmd="$1"; shift
    case "$subcmd" in
        "")         dev ;;
        "w"|"work") work "$@" ;;
        "n"|"new")  mkproj "$@" ;;
        "f"|"fin")  finish-work ;;
        "go"|"p")   p ;;
        "e"|"edit") edit "$@" ;;
        "ai"|"ask") ask "$@" ;;
        "ap")       ask-project "$@" ;;
        "log"|"l")  log "$@" ;;
        "g"|"git")  lazygit ;;
        "z"|"zj")   zellij ;;
        "up")       nix-up ;;
        "check")    audit ;;
        "clean")    cleanup ;;
        "fix")      sz ;;
        *) echo "❌ Unknown: c $subcmd"; echo "💡 Try 'c' for menu." ;;
    esac
}

# Shortcuts
alias g="lazygit"
alias e="edit"
alias z="zoxide"
alias sz="exec zsh"

# Load Env & Functions
[ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"
if [ -d "$DOTFILES/zsh/functions" ]; then
  for f in "$DOTFILES/zsh/functions/"*.zsh; do [ -r "$f" ] && source "$f"; done
fi

# Init
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
