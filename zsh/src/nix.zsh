# =================================================================
# ❄️ Cockpit Nix Module (Robust Edition)
# =================================================================

# --- Helper: Smart Sed (GNU/BSD Compatible) ---
# 環境に応じて sed の書き方を自動で切り替える関数
function _sed_i() {
    if sed --version 2>/dev/null | grep -q GNU; then
        # GNU sed (Linux/Nix) 用: -i に空文字をつけない
        sed -i "$@"
    else
        # BSD sed (macOS標準) 用: -i '' が必要
        sed -i '' "$@"
    fi
}

## System Update
function nix-up() {
    # 念のためPATHを補完 (mvなどが消える事故を防止)
    export PATH="$HOME/.nix-profile/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
    
    local dir="$HOME/dotfiles"
    if [ -n "$(git -C "$dir" status --porcelain)" ]; then
        echo "📦 Auto-committing config changes..."
        git -C "$dir" add .
        git -C "$dir" commit -m "chore(nix): update config via cockpit"
    fi
    echo "🚀 Updating System State..."
    if nh darwin switch "$dir"; then
        echo "✅ System Updated."
        # シェルを安全にリロード
        source ~/.zshrc
    else
        echo "❌ Update Failed."
    fi
}

## Add CLI Tool (to pkgs.nix)
function nix-add() {
    local pkg="$1"; [ -z "$pkg" ] && pkg=$(gum input --placeholder "CLI Package Name (e.g. jq)")
    [ -z "$pkg" ] && return 1
    
    local file="$HOME/dotfiles/nix/pkgs.nix"
    # GNU/BSD両対応のsedを使用
    _sed_i "/^  ];/i \\    $pkg" "$file"
    
    echo "📝 Added '$pkg' to pkgs.nix"
    nix-up
}

## Add App/Font (to darwin.nix)
function cask-add() {
    local pkg="$1"; [ -z "$pkg" ] && pkg=$(gum input --placeholder "App/Font Name (e.g. google-chrome)")
    [ -z "$pkg" ] && return 1
    local file="$HOME/dotfiles/nix/modules/darwin.nix"
    
    if grep -q "\"$pkg\"" "$file"; then echo "⚠️ '$pkg' exists."; return 1; fi

    echo "📝 Adding '$pkg' to darwin.nix..."
    
    # 修正版ロジック:
    # 閉じ括弧 ]; を見つけて、その前に "pkg" を挿入する
    _sed_i "s/\];/ \"$pkg\" \];/" "$file"
    
    nix-up
}

# Aliases
alias up="nix-up"
alias add="nix-add"
alias app="cask-add"
