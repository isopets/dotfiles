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
