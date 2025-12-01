#!/bin/bash
# =================================================================
# 🚑 Cockpit Emergency Restore System (Fixed)
# =================================================================
echo "🚨 Starting Emergency Restoration..."

# 1. 諸悪の根源 (.zshrc) を物理削除
#    (これが存在するとNixが衝突するため、強制削除します)
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    echo "🧹 Removing corrupted .zshrc..."
    rm -f "$HOME/.zshrc"
fi

# 2. Nix環境の強制適用
echo "🚀 Rebuilding Nix environment..."

# nh コマンドがある場合
if command -v nh &>/dev/null; then
    # 修正: --force オプションを削除 (nh home switch はデフォルトで強力です)
    nh home switch "$HOME/dotfiles"
else
    # nh すらない場合の最終手段 (標準コマンド)
    echo "⚠️ 'nh' not found. Using standard nix command..."
    nix run --experimental-features "nix-command flakes" \
        --inputs-from "$HOME/dotfiles" \
        home-manager -- switch --flake "$HOME/dotfiles#isogaiyuto"
fi

# 3. 完了通知
if [ $? -eq 0 ]; then
    echo "✅ Restore Complete. Restarting shell..."
    # 成功したら、その場で zsh に入る
    exec zsh
else
    echo "❌ Restore Failed. Please check the logs above."
fi
