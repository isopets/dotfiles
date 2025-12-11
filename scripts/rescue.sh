#!/bin/bash
echo "🚑 Cockpit Emergency Rescue Protocol Initiated..."

# 1. バックアップ
cp ~/.zshrc ~/.zshrc.broken_$(date +%s)

# 2. .zshrc を「絶対に動く状態」で強制上書き
cat << 'ZSHRC' > ~/.zshrc
# --- Emergency Recovery Config ---
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
export LANG=ja_JP.UTF-8
autoload -Uz compinit && compinit
if command -v starship >/dev/null; then eval "$(starship init zsh)"; fi

# 読み込みエラーの原因になりやすいファイルを一旦無効化
# source ~/dotfiles/zsh/src/productivity_plus.zsh
alias code="open -a 'Visual Studio Code'"
ZSHRC

echo "✅ System Reset to Safe Mode."
echo "   - .zshrc has been reset."
echo "   - Broken config saved to .zshrc.broken_..."
echo "👉 Please restart your terminal."
