# =================================================================
# 💻 Nix Management (Auto-Sync & High-Speed)
# =================================================================

function nix-add() {
    local pkg="$1";
    local dir="$HOME/dotfiles"
    local file="$dir/nix/pkgs.nix"
    
    if [ -z "$pkg" ]; then pkg=$(gum input --placeholder "Package Name (e.g. yq)"); fi
    [ -z "$pkg" ] && return 1
    
    echo "🔍 Adding '$pkg'..."
    if command -v gsed &>/dev/null; then SED="gsed"; else SED="sed"; fi
    "$SED" -i "/^  ];/i \\    $pkg" "$file"
    
    # 変更後、即座に nix-up (Auto-Sync) を呼び出す
    echo "📝 Added. Starting Auto-Sync..."
    nix-up
}

function nix-up() {
    local dir="$HOME/dotfiles"
    
    # 1. 変更の検知
    git -C "$dir" add .
    local diff=$(git -C "$dir" diff --cached)
    
    # 2. 変更がある場合のみ、AIコミットを実行
    if [ -n "$diff" ]; then
        echo "🤖 Detected changes. Generating commit message..."
        
        # AIにメッセージを生成させる (ask関数を利用)
        local prompt="Generate a concise git commit message for these nix config changes (Conventional Commits). Output only the message string:\n\n$diff"
        local msg=$(ask "$prompt" | head -n 1) # 1行だけ取得
        
        if [ -z "$msg" ] || [ "$msg" = "null" ]; then
            msg="chore(nix): update configuration"
        fi
        
        # ユーザーに確認せずとも、「適用したい」という意図は明白なので
        # メッセージを表示して即コミット (嫌なら Ctrl+C で止める猶予を1秒与える)
        echo -e "💬 Commit: \033[1;32m$msg\033[0m"
        sleep 1
        
        git -C "$dir" commit -m "$msg"
    fi

    # 3. 爆速適用 (nh)
    # もう Dirty ではないので警告は出ません
    echo "🚀 Updating Nix Environment..."
    if nh home switch "$dir"; then
        gum style --foreground 82 "✅ Update Complete!"
        # シェルを再起動して設定を即時反映
        exec zsh
    else
        gum style --foreground 196 "❌ Update Failed."
    fi
}

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
