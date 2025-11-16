# --- Modern CLI Tools Settings ---

# 1. zoxide (cd の代わり)
eval "$(zoxide init zsh)"
alias cd="z"

# 2. eza (ls の代わり)
# --icons: アイコン表示 (※Nerd Fontが必要)
# --git: Gitの状態も表示
alias ls="eza --icons --git"
alias ll="eza --icons --git -l"
alias la="eza --icons --git -la"

# 3. bat (cat の代わり)
alias cat="bat"

# 4. lazygit
alias lg="lazygit"

# 5. fzf (Ctrl+R で履歴検索など)
source <(fzf --zsh)