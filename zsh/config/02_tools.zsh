if command -v zoxide &> /dev/null; then eval "$(zoxide init zsh)"; alias cd="z"; fi
if command -v eza &> /dev/null; then alias ls="eza --icons --git"; alias ll="eza --icons --git -l"; fi
if command -v bat &> /dev/null; then alias cat="bat"; fi
if command -v lazygit &> /dev/null; then alias lg="lazygit"; fi
if command -v fzf &> /dev/null; then source <(fzf --zsh); fi
if command -v direnv &> /dev/null; then eval "$(direnv hook zsh)"; fi
if command -v starship &> /dev/null; then eval "$(starship init zsh)"; fi
if command -v mise &> /dev/null; then eval "$(mise activate zsh)"; fi
alias grep="rg"; alias find="fd"; 
