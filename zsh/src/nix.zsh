## System Update
function nix-up() {
    local dir="$HOME/dotfiles"
    
    # 変更があれば自動コミット
    if [ -n "$(git -C "$dir" status --porcelain)" ]; then
        echo "📦 Auto-committing config changes..."
        git -C "$dir" add .
        git -C "$dir" commit -m "chore(nix): update config via cockpit"
    fi

    echo "🚀 Updating System State..."
    if nh darwin switch "$dir"; then
        echo "✅ System Updated."
        # シェル環境をリロードして反映
        source ~/.zshrc
    else
        echo "❌ Update Failed."
    fi
}

## Add CLI Tool (to pkgs.nix)
function nix-add() {
    local pkg="$1";
    [ -z "$pkg" ] && pkg=$(gum input --placeholder "CLI Package Name (e.g. jq, ripgrep)")
    [ -z "$pkg" ] && return 1
    
    # pkgs.nix に追記
    sed -i "" "/^  ];/i \\    $pkg" "$HOME/dotfiles/nix/pkgs.nix"
    echo "📝 Added '$pkg' to pkgs.nix"
    nix-up
}

## Add App/Font (to darwin.nix)
#  Usage: cask-add google-chrome
function cask-add() {
    local pkg="$1";
    [ -z "$pkg" ] && pkg=$(gum input --placeholder "App/Font Name (e.g. google-chrome, font-hackgen)")
    [ -z "$pkg" ] && return 1

    local file="$HOME/dotfiles/nix/modules/darwin.nix"
    
    # 重複チェック
    if grep -q "\"$pkg\"" "$file"; then
        echo "⚠️  '$pkg' is already in configuration."
        return 1
    fi

    echo "📝 Adding '$pkg' to darwin.nix..."
    
    # sedを使って casks = [ ... ]; のリストの中に追記する
    # (現在の単一行フォーマットに対応: 末尾の ]; を "pkg" ]; に置換)
    sed -i '' "s/ \];/ \"$pkg\" \];/" "$file"
    
    nix-up
}

# Aliases
alias up="nix-up"
alias add="nix-add"     # CLIツール追加
alias app="cask-add"    # アプリ追加 (エイリアス)

