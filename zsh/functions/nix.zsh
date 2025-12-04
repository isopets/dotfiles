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
    
    # --- 1. Safe Auto-Commit ---
    git -C "$dir" add .
    local diff=$(git -C "$dir" diff --cached)
    
    if [ -n "$diff" ]; then
        echo "🤖 Auto-committing..."
        local msg=""
        
        # AIが使えるかチェックしてから呼び出す
        if [ -n "$GEMINI_API_KEY" ] && command -v ask >/dev/null; then
            # エラーメッセージが返ってくるのを防ぐため、成功時のみ採用
            local ai_msg=$(ask "Generate git commit message for:\n$diff" 2>/dev/null | head -n 1)
            if [[ -n "$ai_msg" && "$ai_msg" != *"Error"* && "$ai_msg" != *"❌"* ]]; then
                msg="$ai_msg"
            fi
        fi
        
        # AIが失敗、または使えない場合はデフォルト値
        if [ -z "$msg" ]; then
            msg="chore(nix): update configuration"
            echo "⚠️  Using default commit message."
        fi
        
        git -C "$dir" commit -m "$msg"
    fi

    # --- 2. Conflict Resolver ---
    # 競合ファイルの退避
    for file in "$HOME/.zshrc" "$HOME/.zshenv"; do
        [ -f "$file" ] && [ ! -L "$file" ] && mv "$file" "${file}.backup_$(date +%s)"
    done

    # --- 3. Robust Apply (The Fix) ---
    echo "🚀 Updating Cockpit System..."
    
    # nh が使えるかチェックし、使い分ける
    if command -v nh >/dev/null; then
        echo "⚡️ Using 'nh' (Fast Mode)..."
        if nh darwin switch "$dir"; then
            _nix_up_success
        else
            echo "❌ 'nh' failed."
            return 1
        fi
    else
        echo "🐢 'nh' not found. Using standard 'nix' (Bootstrap Mode)..."
        # 権限昇格が必要な場合があるため sudo を考慮（必要ならパスワード入力）
        if sudo nix run nix-darwin -- switch --flake "$dir"; then
            _nix_up_success
        else
            echo "❌ Standard build failed."
            return 1
        fi
    fi
}

# 成功時の共通処理
function _nix_up_success() {
    local dir="$HOME/dotfiles"
    echo "☁️  Syncing to GitHub..."
    git -C "$dir" push origin main 2>/dev/null
    echo "✅ Update Complete! Reloading..."
    
    # サービス再起動
    if command -v yabai >/dev/null; then yabai --restart-service 2>/dev/null; fi
    
    # シェル再起動
    exec zsh
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
