# =================================================================
# ❄️ Cockpit Nix Module (Stable & Alias-Proof)
# =================================================================

# --- Helper: Smart Sed ---
function _sed_i() {
    if sed --version 2>/dev/null | grep -q GNU; then sed -i "$@"; else sed -i '' "$@"; fi
}

## System Update
function nix-up() {
    # 1. PATHを強制的に安定化 (標準コマンドを最優先)
    export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.nix-profile/bin:$PATH"
    
    local dir="$HOME/dotfiles"
    
    if [ -n "$(git -C "$dir" status --porcelain)" ]; then
        echo "📦 Auto-committing config changes..."
        git -C "$dir" add .
        git -C "$dir" commit -m "chore(nix): update config via cockpit"
    fi

    echo "🚀 Updating System State..."
    if nh darwin switch "$dir"; then
        echo "✅ System Updated."
        # リロード
        source ~/.zshrc
        return 0
    else
        echo "❌ Update Failed."
        return 1
    fi
}

## Add CLI Tool
function nix-add() {
    local pkg="$1"; [ -z "$pkg" ] && pkg=$(gum input --placeholder "CLI Package Name")
    [ -z "$pkg" ] && return 1
    _sed_i "/^  ];/i \\    $pkg" "$HOME/dotfiles/nix/pkgs.nix"
    echo "📝 Added '$pkg' to pkgs.nix"
    nix-up
}

## Add App/Font (Alias-Proof Edition)
function cask-add() {
    local force_trust=false
    local pkg=""

    for arg in "$@"; do
        if [[ "$arg" == "-y" || "$arg" == "--yes" ]]; then
            force_trust=true
        elif [[ -z "$pkg" ]]; then
            pkg="$arg"
        fi
    done

    [ -z "$pkg" ] && pkg=$(gum input --placeholder "App Name")
    [ -z "$pkg" ] && return 1

    local file="$HOME/dotfiles/nix/modules/darwin.nix"
    if grep -q "\"$pkg\"" "$file"; then echo "⚠️ '$pkg' exists."; return 1; fi

    echo "📝 Adding '$pkg' to darwin.nix..."
    _sed_i "/casks =/s/\];/ \"$pkg\" \];/" "$file"
    
    nix-up
    local update_status=$?
    
    # === 🛡️ Smart Gatekeeper Logic ===
    if [ $update_status -eq 0 ]; then
        echo "🔍 Scanning for installed app..."
        
        # 修正ポイント: 
        # エイリアス(find=fd)を回避するため、絶対パス '/usr/bin/find' を使用
        local app_path=$(/usr/bin/find /Applications -maxdepth 1 -iname "*${pkg}*.app" | head -1)
        
        if [ -n "$app_path" ]; then
            local app_name=$(basename "$app_path")
            
            if [ "$force_trust" = true ]; then
                echo "🔓 Trusted Mode (-y): Unlocking $app_name..."
                sudo xattr -d com.apple.quarantine "$app_path" 2>/dev/null
                echo "✅ Ready to launch!"
            else
                echo ""
                if gum confirm "🛡️ Security Check: Trust & Unlock '$app_name'?"; then
                    echo "🔓 Unlocking..."
                    sudo xattr -d com.apple.quarantine "$app_path" 2>/dev/null
                    echo "✅ Allowed."
                else
                    echo "🔒 Kept in Quarantine."
                fi
            fi
        else
            # フォントなどの場合はアプリが見つからないので、エラーではなくスキップ扱い
            echo "ℹ️  No .app file found (might be a font or CLI tool). Skipping unlock."
        fi
    fi
}

# Aliases
alias up="nix-up"
alias add="nix-add"
alias app="cask-add"
