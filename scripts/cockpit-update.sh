#!/bin/bash
# Cockpit System Update Wrapper (Using darwin-rebuild)

# 1. パスと環境変数の設定
export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
# Flakeがあるディレクトリ
DIR="$HOME/dotfiles"

# 2. ディレクトリに移動
cd "$DIR" || exit 1

echo "🔄 Running darwin-rebuild switch (Root Mode)..."

# 3. 本家のコマンドを実行 (これはRootで実行されてもOK)
#    --flake .# : カレントディレクトリのflakeを使う
darwin-rebuild switch --flake .#

# 4. 完了後のオーナー修正 (念の為、gitなどの権限ズレを防ぐ)
#    SUDO_USER は sudo を実行した元のユーザー名
if [ -n "$SUDO_USER" ]; then
    chown -R "$SUDO_USER" "$DIR"
fi
