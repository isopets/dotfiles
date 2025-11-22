if command -v zoxide &> /dev/null; then eval "$(zoxide init zsh)"; alias cd="z"; fi
if command -v eza &> /dev/null; then
    alias ls="eza --icons --git"; alias ll="eza --icons --git -l"; alias la="eza --icons --git -la"
fi
if command -v bat &> /dev/null; then alias cat="bat"; fi
if command -v lazygit &> /dev/null; then alias lg="lazygit"; fi
if command -v fzf &> /dev/null; then source <(fzf --zsh); fi
if command -v direnv &> /dev/null; then eval "$(direnv hook zsh)"; fi
if command -v starship &> /dev/null; then eval "$(starship init zsh)"; fi
# mise (Language Manager)
if command -v mise &> /dev/null; then eval "$(mise activate zsh)"; fi

# Sheldon (Warp以外で有効化)
if [[ "$TERM_PROGRAM" != "Warp.app" ]]; then
    if command -v sheldon &> /dev/null; then
        eval "$(sheldon --config-file ~/dotfiles/sheldon/plugins.toml source)"
    fi
fi

alias grep="rg"; alias find="fd"; alias du="dust"; alias top="btop"; alias help="tldr"; alias lzd="lazydocker"
alias chrome-work='open -n -a "Google Chrome" --args --user-data-dir="$HOME/dotfiles/chrome/profiles/work"'
alias chrome-personal='open -n -a "Google Chrome" --args --user-data-dir="$HOME/dotfiles/chrome/profiles/personal"'
