# =================================================================
# 💻 Nix Management Functions
# =================================================================

function nix-add() {
    local pkg="$1";
    local file="$HOME/dotfiles/nix/pkgs.nix"
    if [ -z "$pkg" ]; then pkg=$(gum input --placeholder "Package Name"); fi
    [ -z "$pkg" ] && return 1
    echo "🔍 Adding '$pkg'..."
    # gsedがなければsedを使う安全策
    if command -v gsed &>/dev/null; then SED="gsed"; else SED="sed"; fi
    
    # pkgs.nix にパッケージを追記
    $SED -i "/^  ];/i \\    $pkg" "$file"
    
    echo "📝 Added."
    if gum confirm "Apply now?"; then nix-up; else echo "⚠️ Saved."; fi
}

function nix-up() {
    echo "🚀 Updating Nix Environment..."
    local dir="$HOME/dotfiles"
    
    # Gitに記録
    git -C "$dir" add .
    git -C "$dir" commit -m "config: Update config (modules)" 2>/dev/null
    
    # 適用実行 (バージョン固定)
    if nix --experimental-features "nix-command flakes" run --inputs-from "$dir" home-manager -- switch --flake "$dir#isogaiyuto"; then
        gum style --foreground 82 "✅ Update Complete!"
        [cite_start]sz # Shellを再起動して新しい環境を反映 [cite: 30]
    else
        gum style --foreground 196 "❌ Update Failed."
    fi
}

function nix-edit() { code ~/dotfiles/nix/pkgs.nix; }
function nix-clean() { nix-collect-garbage -d; echo "✨ Cleaned."; }

# =================================================================
# 🤖 AI GitOps Functions
# =================================================================

function nix-commit() {
    local dir="$HOME/dotfiles"
    
    # Git差分を確認
    git -C "$dir" add .
    local diff=$(git -C "$dir" diff --cached)
    
    if [ -z "$diff" ]; then
        echo "💡 変更がありません。nix-up を実行します。"
        nix-up
        return 0
    fi

    echo "🤖 差分からコミットメッセージを生成中..."
    
    if [ -n "$GEMINI_API_KEY" ]; then
        local prompt="You are a commit message generator. Based on the following Nix configuration changes, generate a concise, conventional commit message (e.g., feat(module): add new tool). Focus on the core change. Changes:\n\n$diff"
        
        # AIにコミットメッセージを生成させる
        local msg=$(curl -s -H "Content-Type: application/json" \
            -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$prompt\" }] }] }" \
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
            | jq -r '.candidates[0].content.parts[0].text' | head -n 1) # 最初の行だけを取得

        if [ -z "$msg" ]; then
            msg="chore(config): auto-commit changes"
            echo "⚠️ AI生成失敗。デフォルトメッセージを使用します。"
        fi
        
    else
        echo "❌ GEMINI_API_KEYが設定されていません。手動でコミットしてください。"
        return 1
    fi

    # コミットと適用
    gum confirm "🤖 コミットメッセージ案: '$msg' を使用しますか?" && \
    git -C "$dir" commit -m "$msg" && \
    nix-up || echo "👋 コミットはキャンセルされました。"
}

# 既存のnix-upをnix-commitを経由するように変更 (オプション)
# 現状は手動で nix-commit を呼ぶ運用を推奨
