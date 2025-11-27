# System & Config Aliases
alias zshconfig="code ~/.zshrc"
alias sz="source ~/.zshrc"
alias dot="cd ~/dotfiles"
alias brew-backup="brew bundle dump --file=~/dotfiles/macos/Brewfile --force"
alias o="open ."

# Documentation
alias rules="bat ~/dotfiles/docs/WORKFLOW.md"
alias edit-rules="code ~/dotfiles/docs/WORKFLOW.md"

# VS Code Config
alias edit-vscode="code ~/dotfiles/vscode/source"
alias update-vscode="~/dotfiles/vscode/update_settings.sh"
alias unlock-vscode="find \"$HOME/Library/Application Support/Code/User/profiles\" -name settings.json -exec chmod +w {} \;"

# Utils
alias diff-vscode="~/dotfiles/zsh/config/04_functions.zsh diff-vscode-cli" # ※これは functions/vscode.zsh に移行済みだが互換性のため残す
alias copy-key="echo -n \$GEMINI_API_KEY | pbcopy && echo '✅ API Key copied!'"

# Mode Switch
alias expert-on="touch $HOME/.dotfiles_expert_mode && echo '😎 Expert Mode: ON'"
alias expert-off="rm -f $HOME/.dotfiles_expert_mode && echo '👶 Beginner Mode: ON'"

# Task Alias
alias done="finish-work"