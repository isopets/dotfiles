function _get_pkg_version() { nix eval --raw "github:NixOS/nixpkgs/${1}#${2}.version" 2>/dev/null; }

function nix-add() {
    local pkg="$1"; local force_auto="$2"
    local file="$HOME/dotfiles/nix/pkgs.nix"
    [ -z "$pkg" ] && pkg=$(gum input --placeholder "📦 Package") && [ -z "$pkg" ] && return 1
    
    if grep -q "$pkg" "$file"; then echo "✅ Already installed."; return 0; fi

    echo "🔍 Checking versions..."
    local v_stable=$(_get_pkg_version "nixos-24.05" "$pkg")
    local v_unstable=$(_get_pkg_version "nixos-unstable" "$pkg")
    local channel="stable"
    
    if [ -z "$v_stable" ] && [ -z "$v_unstable" ]; then echo "❌ Not found."; return 1; fi

    if [ "$force_auto" != "auto" ] && [ "$v_unstable" != "$v_stable" ]; then
        local mode=$(gum choose "🛡️ Stable ($v_stable)" "🚀 Unstable ($v_unstable)")
        [[ "$mode" == *"Unstable"* ]] && channel="unstable"
    elif [ "$v_unstable" != "$v_stable" ]; then
        channel="unstable"
    fi

    local str="    $pkg"
    [ "$channel" = "unstable" ] && str="    pkgs-unstable.$pkg"
    
    if command -v gsed &>/dev/null; then SED="gsed"; else SED="sed"; fi
    "$SED" -i "/^  ];/i \\$str" "$file"
    echo "📝 Added $str"
    nix-up
}

function nix-up() {
    local dir="$HOME/dotfiles"
    git -C "$dir" add .
    if [ -n "$(git -C "$dir" diff --cached)" ]; then
        echo "🤖 Auto-committing..."
        local msg="chore(nix): update configuration"
        [ -n "$GEMINI_API_KEY" ] && msg=$(ask "Generate commit msg for:\n$(git -C "$dir" diff --cached)" | head -n 1)
        git -C "$dir" commit -m "$msg"
    fi
    
    # Conflict Resolver
    for file in "$HOME/.zshrc" "$HOME/.zshenv"; do
        [ -f "$file" ] && [ ! -L "$file" ] && mv "$file" "${file}.backup_$(date +%s)"
    done

    echo "🚀 Updating Cockpit (Darwin)..."
    if nh darwin switch "$dir"; then
        echo "☁️ Syncing..."
        git -C "$dir" push origin main 2>/dev/null
        echo "✅ Done."
        if command -v sz &>/dev/null; then sz; else exec zsh; fi
    else
        echo "❌ Failed."
        return 1
    fi
}

function nix-update() {
    local dir="$HOME/dotfiles"
    echo "🔄 Updating flake.lock..."
    nix flake update --flake "$dir"
    echo "🏗️  Previewing..."
    nh darwin build "$dir" --diff
    gum confirm "🚀 Apply?" && nix-up || git -C "$dir" checkout flake.lock
}

# Shortcuts
function nix-edit() { code ~/dotfiles; }
function nix-clean() { echo "✨ Cleaning..."; nh clean all --keep 7d; }
