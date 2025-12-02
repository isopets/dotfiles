# =================================================================
# 💻 Nix Management (Smart Installer & Upgrader)
# =================================================================

# --- 🧠 Internal: Version Intelligence ---
function _get_pkg_version() {
    local channel="$1" # "nixos-24.05" or "nixos-unstable"
    local pkg="$2"
    # nix eval でバージョンを取得 (エラーなら空文字)
    nix eval --raw "github:NixOS/nixpkgs/${channel}#${pkg}.version" 2>/dev/null
}

function nix-add() {
    local pkg="$1"
    local force_auto="$2"
    
    local dir="$HOME/dotfiles"
    local file_pkgs="$dir/nix/pkgs.nix"
    
    if [ -z "$pkg" ]; then pkg=$(gum input --placeholder "📦 Package Name"); fi
    [ -z "$pkg" ] && return 1
    
    echo "🔍 Checking status for '$pkg'..."

    # 1. 状態判定 (Status Check)
    local current_state="none"
    
    if grep -q "pkgs-unstable.$pkg" "$file_pkgs" "$dir/nix/modules/shell.nix"; then
        current_state="unstable"
    elif grep -q "[[:space:]]$pkg[[:space:]]*$" "$file_pkgs"; then
        current_state="stable"
    fi

    # 2. バージョン情報の取得
    local v_stable=$(_get_pkg_version "nixos-24.05" "$pkg")
    local v_unstable=$(_get_pkg_version "nixos-unstable" "$pkg")

    if [ -z "$v_stable" ] && [ -z "$v_unstable" ]; then
        echo "❌ Package '$pkg' not found in Nixpkgs."
        return 1
    fi

    # 3. ロジック分岐
    if [ "$current_state" = "unstable" ]; then
        # 既に最強の状態
        gum style --foreground 82 "✅ '$pkg' is already on Unstable ($v_unstable)."
        return 0
        
    elif [ "$current_state" = "stable" ]; then
        # Stableに入っている場合 -> アップデート提案
        gum style --foreground 220 "⚠️  '$pkg' is currently installed (Stable: $v_stable)."
        
        if [ "$v_unstable" != "$v_stable" ]; then
            echo "🚀 Newer version available in Unstable: $v_unstable"
            if gum confirm "Upgrade '$pkg' to Unstable ($v_unstable)?"; then
                echo "⚡ Upgrading to Unstable..."
                # sedで置換: "  pkg" -> "  pkgs-unstable.pkg"
                if command -v gsed &>/dev/null; then SED="gsed"; else SED="sed"; fi
                "$SED" -i "s/^[[:space:]]*$pkg[[:space:]]*$/    pkgs-unstable.$pkg/" "$file_pkgs"
                nix-up
                return 0
            else
                echo "🛡️  Keeping Stable version."
                return 0
            fi
        else
            echo "🍵 No newer version in Unstable."
            return 0
        fi
        
    else
        # 新規インストール (前回と同じロジック)
        local target_channel="stable"
        local pkg_str="    $pkg"
        
        if [ "$force_auto" != "auto" ]; then
            echo "📊 Versions: [Stable: ${v_stable:-N/A}] vs [Unstable: ${v_unstable:-N/A}]"
            local mode=$(gum choose --cursor.foreground="214" "🛡️  Use Stable" "🚀 Use Unstable")
            if [[ "$mode" == *"Unstable"* ]]; then target_channel="unstable"; fi
        elif [ -n "$v_unstable" ] && [ "$v_unstable" != "$v_stable" ]; then
            target_channel="unstable"
        fi

        if [ "$target_channel" = "unstable" ]; then pkg_str="    pkgs-unstable.$pkg"; fi
        
        # 追記
        if command -v gsed &>/dev/null; then SED="gsed"; else SED="sed"; fi
        "$SED" -i "/^  ];/i \\$pkg_str" "$file_pkgs"
        echo "📝 Added '$pkg_str'"
        nix-up
    fi
}

function nix-up() {
    local dir="$HOME/dotfiles"
    
    # Auto-Commit
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

    # Conflict Resolver
    for file in "$HOME/.zshrc" "$HOME/.zshenv"; do
        [ -f "$file" ] && [ ! -L "$file" ] && mv "$file" "${file}.backup_$(date +%s)"
    done

    # Apply & Reload
    echo "🚀 Updating Nix Environment..."
    if nh home switch "$dir"; then
        echo "☁️  Syncing to GitHub..."
        git -C "$dir" push origin main 2>/dev/null
        gum style --foreground 82 "✅ Update Complete!"
        # sz があれば使う、なければ exec zsh
        if command -v sz &>/dev/null; then sz; else exec zsh; fi
    else
        gum style --foreground 196 "❌ Update Failed."
        return 1
    fi
}

# --- Shortcuts ---
function nix-edit() { 
    local menu="pkgs.nix\ncore.nix\nshell.nix\nzsh.nix\nneovim.nix\nvscode.nix"
    local s=$(echo -e "$menu" | fzf --prompt="📝 Edit > " --height=40% --layout=reverse)
    case "$s" in
        "pkgs.nix") code ~/dotfiles/nix/pkgs.nix ;;
        *) [ -n "$s" ] && code ~/dotfiles/nix/modules/$s ;;
    esac
}

function nix-clean() { echo "✨ Cleaning..."; nh clean all --keep 7d; }
# --- 🔄 System Update (Safe Mode with nvd) ---
function nix-update() {
    local dir="$HOME/dotfiles"
    echo "🔄 Fetching latest package versions (Updating flake.lock)..."
    
    # 1. カタログ(flake.lock)を最新に更新
    nix flake update --flake "$dir"
    
    # 2. ビルドして差分を確認 (適用はまだしない)
    echo "🏗️  Building new configuration for preview..."
    # 現在の世代と、新しい設定のビルド結果を比較
    local current_gen=$(readlink -f ~/.nix-profile)
    local new_gen=$(nix build --no-link --print-out-paths "$dir#homeConfigurations.isogaiyuto.activationPackage")
    
    # activationPackageから実際のプロファイルパスへ少し調整が必要ですが、
    # nh を使っているなら nh が nvd 連携機能を持っています。
    # ここでは最も簡単な nh の diff機能 を使います。
    
    echo ""
    gum style --foreground 214 --bold "🔍 Update Preview:"
    
    # nh を使って差分を表示 (nvdが必要)
    nh home build "$dir" --diff || echo "⚠️ Diff generation failed."
    
    echo ""
    # 3. ユーザーの承認
    if gum confirm "🚀 Apply these updates?"; then
        echo "🚀 Applying updates..."
        nix-up
    else
        echo "🛡️  Update canceled. Reverting flake.lock..."
        git -C "$dir" checkout flake.lock
        echo "✅ Reverted."
    fi
}
