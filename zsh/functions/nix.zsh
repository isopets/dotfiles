# =================================================================
# 💻 Nix Management (Auto-Sync, Push & Robust Reload)
# =================================================================

function nix-add() {
    local pkg="$1"
    local dir="$HOME/dotfiles"
    local file="$dir/nix/pkgs.nix"
    
    # 1. パッケージ名の入力
    if [ -z "$pkg" ]; then 
        pkg=$(gum input --placeholder "📦 Package Name (e.g. neovim)")
    fi
    [ -z "$pkg" ] && return 1
    
    echo "🔍 Checking versions for '$pkg'..."

    # 2. バージョン情報の取得 (nix search は遅いので、簡易的に web検索か、あるいはdry-run的な確認がベストだが、
    #    ここではシンプルに「チャンネル選択」をユーザーに委ねるUIにする)
    #    ※ 本当に厳密なバージョン比較はAPIを叩く必要があるため、今回は「意図」で選ぶUIにします。

    local mode=$(gum choose \
        "🛡️  Stable    (Reliability First)" \
        "🚀 Unstable  (Newest Features)" \
        "❌ Cancel")

    local pkg_str=""
    
    case "$mode" in
        *"Stable"*)
            pkg_str="    $pkg"
            echo "📦 Selected: Stable Channel"
            ;;
        *"Unstable"*)
            pkg_str="    pkgs-unstable.$pkg"
            echo "🚀 Selected: Unstable Channel"
            ;;
        *)
            echo "👋 Canceled."
            return 1
            ;;
    esac
    
    # 3. pkgs.nix への追記
    # sedを使ってリストの末尾（];の前）に挿入
    if command -v gsed &>/dev/null; then SED="gsed"; else SED="sed"; fi
    "$SED" -i "/^  ];/i \\$pkg_str" "$file"
    
    echo "📝 Added '$pkg_str' to pkgs.nix"
    
    # 4. Auto-Sync
    nix-up
}

function nix-up() {
    local dir="$HOME/dotfiles"
    
    # 1. 変更検知 & 自動コミット
    git -C "$dir" add .
    local diff=$(git -C "$dir" diff --cached)
    
    if [ -n "$diff" ]; then
        echo "🤖 Detected changes. Auto-committing..."
        local msg=$(ask "Generate a git commit message for these changes (Conventional Commits). Output only the string:\n\n$diff" | head -n 1)
        [ -z "$msg" ] && msg="chore(nix): update configuration"
        
        echo -e "💬 Commit: \033[1;32m$msg\033[0m"
        git -C "$dir" commit -m "$msg"
    fi

    # 2. 競合ファイルの自動退避
    for file in "$HOME/.zshrc" "$HOME/.zshenv"; do
        if [ -f "$file" ] && [ ! -L "$file" ]; then
            echo "🧹 Backing up conflicting file: $file"
            mv "$file" "${file}.backup_$(date +%s)"
        fi
    done

    # 3. 爆速適用 & ロバスト・リロード
    echo "🚀 Updating Nix Environment..."
    if nh home switch "$dir"; then
        echo "☁️  Syncing to GitHub..."
        git -C "$dir" push origin main 2>/dev/null || echo "⚠️ Push failed. Local is updated."
        
        gum style --foreground 82 "✅ Update Complete! Reloading..."
        
        # ★ 改善点: sz があれば使い、なければ exec zsh を使う
        if command -v sz &>/dev/null; then
            sz
        else
            echo "🔄 'sz' not found yet. Falling back to standard reload."
            exec zsh
        fi
    else
        gum style --foreground 196 "❌ Update Failed."
        return 1
    fi
}

# --- Other Functions ---
function nix-edit() { 
    local menu_items="pkgs.nix\ncore.nix\nshell.nix\nvscode.nix\nneovim.nix\nzsh.nix"
    local selected=$(echo -e "$menu_items" | fzf --prompt="📝 Edit Module > " --height=40% --layout=reverse)
    case "$selected" in
        "pkgs.nix") code ~/dotfiles/nix/pkgs.nix ;;
        "core.nix") code ~/dotfiles/nix/modules/core.nix ;;
        "shell.nix") code ~/dotfiles/nix/modules/shell.nix ;;
        "zsh.nix") code ~/dotfiles/nix/modules/zsh.nix ;;
        "vscode.nix") code ~/dotfiles/nix/modules/vscode.nix ;;
        "neovim.nix") code ~/dotfiles/nix/modules/neovim.nix ;;
    esac
}

function nix-clean() { 
    echo "✨ Cleaning Nix store..."
    nh clean all --keep 7d 
}

function nix-history() {
    local generations=$(home-manager generations | head -n 30)
    [ -z "$generations" ] && echo "❌ No history." && return 1
    local selected=$(echo "$generations" | gum choose --height 10 --header "🕰️ Select Generation to Restore:")
    if [ -n "$selected" ]; then
        local gen_path=$(echo "$selected" | awk '{print $7}')
        if gum confirm "Rollback to this state?"; then
            "$gen_path/activate"
            echo "✅ Rolled back."
            if command -v sz &>/dev/null; then sz; else exec zsh; fi
        fi
    fi
}

# --- 🔄 System Update (Update Flake Lock) ---
function nix-update() {
    local dir="$HOME/dotfiles"
    echo "🔄 Fetching latest package versions (Stable & Unstable)..."
    
    # 1. カタログ(flake.lock)を最新に更新
    nix flake update --flake "$dir"
    
    # 2. 自動コミット & 適用 (既存のnix-upを呼び出す)
    echo "🚀 Applying updates..."
    nix-up
}