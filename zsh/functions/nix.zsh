# =================================================================
# 💻 Nix Management (Darwin Edition)
# =================================================================

# --- 🧠 Internal: Version Intelligence ---
function _get_pkg_version() {
    local channel="$1" 
    local pkg="$2"
    nix eval --raw "github:NixOS/nixpkgs/${channel}#${pkg}.version" 2>/dev/null
}

function nix-add() {
    local pkg="$1"; local force_auto="$2"
    local dir="$HOME/dotfiles"
    local file_pkgs="$dir/nix/pkgs.nix"
    
    if [ -z "$pkg" ]; then pkg=$(gum input --placeholder "📦 Package Name"); fi
    [ -z "$pkg" ] && return 1
    
    # 1. 重複チェック
    if grep -q "[[:space:]]$pkg[[:space:]]*$" "$file_pkgs"; then
        gum style --foreground 82 "✅ '$pkg' is already in pkgs.nix (Stable)"
        return 0
    elif grep -q "pkgs-unstable.$pkg" "$file_pkgs" "$dir/nix/modules/shell.nix"; then
        gum style --foreground 82 "✅ '$pkg' is already in configuration (Unstable)"
        return 0
    fi

    # 2. バージョン比較
    echo "🔍 Checking versions for '$pkg'..."
    local v_stable=$(_get_pkg_version "nixos-24.05" "$pkg")
    local v_unstable=$(_get_pkg_version "nixos-unstable" "$pkg")

    if [ -z "$v_stable" ] && [ -z "$v_unstable" ]; then
        echo "❌ Package '$pkg' not found."
        return 1
    fi

    local target_channel="stable"
    local pkg_str="    $pkg"
    
    if [ "$force_auto" != "auto" ]; then
        echo "📊 Versions: [Stable: ${v_stable:-N/A}] vs [Unstable: ${v_unstable:-N/A}]"
        if [ -n "$v_unstable" ] && [ "$v_unstable" != "$v_stable" ]; then
             local mode=$(gum choose --cursor.foreground="214" "🛡️  Use Stable" "🚀 Use Unstable")
             if [[ "$mode" == *"Unstable"* ]]; then target_channel="unstable"; fi
        fi
    elif [ -n "$v_unstable" ] && [ "$v_unstable" != "$v_stable" ]; then
        target_channel="unstable"
    fi

    if [ "$target_channel" = "unstable" ]; then pkg_str="    pkgs-unstable.$pkg"; fi
    
    if command -v gsed &>/dev/null; then SED="gsed"; else SED="sed"; fi
    "$SED" -i "/^  ];/i \\$pkg_str" "$file_pkgs"
    
    echo "📝 Added '$pkg_str'"
    nix-up
}

function nix-up() {
    local dir="$HOME/dotfiles"
    
    # 1. Auto-Commit
    git -C "$dir" add .
    local diff=$(git -C "$dir" diff --cached)
    if [ -n "$diff" ]; then
        echo "🤖 Auto-committing..."
        local msg="chore(nix): update configuration"
        if [ -n "$GEMINI_API_KEY" ] && command -v ask &>/dev/null; then
             msg=$(ask "Generate git commit message for:\n$diff" | head -n 1)
        fi
        git -C "$dir" commit -m "$msg"
    fi

    # 2. Conflict Resolver
    for file in "$HOME/.zshrc" "$HOME/.zshenv"; do
        [ -f "$file" ] && [ ! -L "$file" ] && mv "$file" "${file}.backup_$(date +%s)"
    done

    # 3. Apply (Darwin Switch)
    echo "🚀 Updating Cockpit System (Darwin)..."
    
    # 🚨 ここを Darwin 用に一本化
    if nh darwin switch "$dir"; then
        echo "☁️  Syncing to GitHub..."
        git -C "$dir" push origin main 2>/dev/null
        gum style --foreground 82 "✅ Update Complete! Reloading..."
        
        if command -v yabai >/dev/null; then yabai --restart-service 2>/dev/null; fi
        if command -v sz &>/dev/null; then sz; else exec zsh; fi
    else
        gum style --foreground 196 "❌ Update Failed."
        return 1
    fi
}

# --- Shortcuts ---
function nix-edit() { 
    local menu="pkgs.nix\ncore.nix\nshell.nix\nzsh.nix\nneovim.nix\nvscode.nix\ndarwin.nix"
    local s=$(echo -e "$menu" | fzf --prompt="📝 Edit > " --height=40% --layout=reverse)
    case "$s" in
        "pkgs.nix") code ~/dotfiles/nix/pkgs.nix ;;
        *) [ -n "$s" ] && code ~/dotfiles/nix/modules/$s ;;
    esac
}

function nix-clean() { echo "✨ Cleaning..."; nh clean all --keep 7d; }

function nix-update() {
    local dir="$HOME/dotfiles"
    echo "🔄 Updating flake.lock..."
    nix flake update --flake "$dir"
    
    echo "🏗️  Previewing updates..."
    # Darwin 用のプレビューコマンドに変更
    nh darwin build "$dir" --diff || echo "⚠️ Diff generation failed."
    
    if gum confirm "🚀 Apply these updates?"; then
        nix-up
    else
        echo "🛡️  Reverting..."
        git -C "$dir" checkout flake.lock
        echo "✅ Reverted."
    fi
}