# =================================================================
# ❄️ Cockpit Nix Module (Smart Security Edition)
# =================================================================

# --- Helper: Smart Sed ---
function _sed_i() {
    if sed --version 2>/dev/null | grep -q GNU; then sed -i "$@"; else sed -i '' "$@"; fi
}

## System Update
function nix-up() {
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
        export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
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

## Add App/Font (Trust-Verify Protocol)
function cask-add() {
    local force_trust=false
    local pkg=""

    # 引数解析 (-y オプションの検知)
    for arg in "$@"; do
        if [[ "$arg" == "-y" || "$arg" == "--yes" ]]; then
            force_trust=true
        elif [[ -z "$pkg" ]]; then
            pkg="$arg"
        fi
    done

    [ -z "$pkg" ] && pkg=$(gum input --placeholder "App Name (e.g. google-chrome)")
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
        local app_path=$(find /Applications -maxdepth 1 -iname "*${pkg}*.app" | head -1)
        
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
                    echo "✅ Allowed. You can open it safely."
                else
                    echo "🔒 Kept in Quarantine."
                fi
            fi
        fi
    fi
}

alias up="nix-up"
alias add="nix-add"
alias app="cask-add"
