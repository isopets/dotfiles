# =================================================================
# 💻 Nix Management Functions (Fixed for nh syntax)
# =================================================================

function nix-add() {
    local pkg="$1";
    local dir="$HOME/dotfiles"
    local file="$dir/nix/pkgs.nix"
    
    if [ -z "$pkg" ]; then pkg=$(gum input --placeholder "Package Name (e.g. yq)"); fi
    [ -z "$pkg" ] && return 1
    
    echo "🔍 Adding '$pkg' to pkgs.nix..."
    
    if command -v gsed &>/dev/null; then SED="gsed"; else SED="sed"; fi
    "$SED" -i "/^  ];/i \\    $pkg" "$file"
    
    echo "�� Added. Ready for deployment."
    
    if gum confirm "Commit 'feat(pkg): add $pkg' and Apply now?"; then
        git -C "$dir" add "$file"
        git -C "$dir" commit -m "feat(pkg): add $pkg"
        nix-up
    else 
        echo "⚠️ 変更は保存されましたが、適用されていません。"
    fi
}

function nix-up() {
    echo "🚀 Updating Nix Environment with nh..."
    local dir="$HOME/dotfiles"
    
    # 【修正点】nh build home -> nh home switch "$dir"
    # nh home switch <flake-uri> 形式で実行します
    if nh home switch "$dir"; then
        gum style --foreground 82 "✅ Update Complete!"
        sz # Shellを再起動して新しい環境を反映
    else
        gum style --foreground 196 "❌ Update Failed."
    fi
}

function nix-edit() { 
    local menu_items="pkgs.nix (Packages)
core.nix (User/Home Dir)
shell.nix (Zsh/Starship/Git)
vscode.nix (Global VS Code)"
    local selected=$(echo "$menu_items" | fzf --prompt="📝 Select Module to Edit > ")
    
    case "$selected" in
        *"pkgs.nix"*) code ~/dotfiles/nix/pkgs.nix ;;
        *"core.nix"*) code ~/dotfiles/nix/modules/core.nix ;;
        *"shell.nix"*) code ~/dotfiles/nix/modules/shell.nix ;;
        *"vscode.nix"*) code ~/dotfiles/nix/modules/vscode.nix ;;
        *) echo "👋 Canceled." ;;
    esac
}

function nix-clean() { 
    echo "✨ Cleaning Nix store with nh..."
    nh clean all --keep 7d 
}

# --- 🕰️ Time Machine (History & Rollback) ---
function nix-history() {
    echo "🔍 Retrieving system generations..."
    
    # Home Managerの世代リストを取得し、逆順(最新が上)にしてFZFに渡す
    # 形式: ID Date Time
    local generations=$(home-manager generations | head -n 30)
    
    if [ -z "$generations" ]; then
        echo "❌ No history found."
        return 1
    fi
    
    local selected=$(echo "$generations" | gum choose --height 10 --header "🕰️ Select a Generation to Restore:")
    
    if [ -n "$selected" ]; then
        # IDを抽出
        local gen_id=$(echo "$selected" | awk '{print $5}')
        local gen_path=$(echo "$selected" | awk '{print $7}')
        
        echo "⚠️  You are about to switch to Generation $gen_id"
        echo "📂 Path: $gen_path"
        
        if gum confirm "Activate this generation?"; then
            echo "🚀 Time travelling..."
            "$gen_path/activate"
            gum style --foreground 82 "✅ System restored to Generation $gen_id"
            sz
        else
            echo "👋 Canceled."
        fi
    fi
}
