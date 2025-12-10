# =================================================================
# ❄️ Cockpit Nix Module (Hybrid Auth Edition)
# [AI_NOTE]
# - HUD表示 (Zellij Floating)
# - パスワード入力最優先のUIに変更
# - 成功時自動クローズ
# =================================================================

UPDATE_SCRIPT="$HOME/dotfiles/scripts/cockpit-update.sh"

function nix-up() {
    # コマンド構築:
    # 1. ユーザーに明確にパスワードを求めるメッセージを表示
    # 2. sudo -v で認証 (パスワード入力待機)
    # 3. 成功したら更新実行
    
    local cmd="echo '🔑 Auth Required: Enter Password (or use Touch ID)'; \
    echo '------------------------------------------------'; \
    if sudo -v; then \
        echo ''; echo '🚀 Auth Accepted. Updating System...'; \
        if sudo $UPDATE_SCRIPT; then \
            osascript -e 'display notification \"System Updated 🚀\" with title \"Cockpit\"'; \
            echo '✅ Update Complete. Closing in 3 seconds...'; \
            sleep 3; \
        else \
            osascript -e 'display notification \"Update Failed ⚠️\" with title \"Cockpit\"'; \
            echo '❌ Update Failed. Press Enter to close.'; \
            read; \
        fi \
    else \
        echo '❌ Authentication Cancelled.'; \
        read; \
    fi"

    # Zellijの中にいるかチェック
    if [ -n "$ZELLIJ" ]; then
        # 🛰️ HUDモード
        # 幅と高さを少し小さくして、ダイアログっぽくする
        zellij run --name "🔑 System Auth" --floating --width 60% --height 50% --close-on-exit -- bash -c "$cmd"
    else
        # 通常モード
        bash -c "$cmd"
    fi
}

function nix-add() {
    [ -z "$1" ] && return 1
    sed -i '' "/^  ];/i \\    $1" "$HOME/dotfiles/nix/pkgs.nix"
    echo "📝 Added $1"
    nix-up
}

function cask-add() {
    [ -z "$1" ] && return 1
    local file="$HOME/dotfiles/nix/modules/darwin.nix"
    if grep -q "\"$1\"" "$file"; then echo "⚠️ Exists."; return 1; fi
    sed -i '' "/casks =/s/\];/ \"$1\" \];/" "$file"
    echo "📝 Added $1"
    nix-up
}

alias up="nix-up"
alias add="nix-add"
alias app="cask-add"
