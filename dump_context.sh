#!/bin/bash
timestamp=$(date "+%Y%m%d_%H%M%S")
outfile="$HOME/Desktop/cockpit_dump_${timestamp}.txt"

echo "📦 Dumping Cockpit Context to: $outfile"

{
    echo "=== COCKPIT SNAPSHOT: ${timestamp} ==="
    echo "User: $(whoami)"
    echo "Host: $(scutil --get LocalHostName)"
    echo ""
    
    echo "--- FILE TREE ---"
    if command -v eza >/dev/null; then
        eza --tree --level=4 -a -I ".git|node_modules|.DS_Store|.cache" "$HOME/dotfiles"
    else
        find "$HOME/dotfiles" -maxdepth 4 -not -path '*/.*'
    fi
    echo ""

    echo "--- FILE CONTENTS ---"
    
    # 診断に必要な重要ファイルのリスト
    files=(
        "$HOME/dotfiles/flake.nix"
        "$HOME/dotfiles/home.nix"
        "$HOME/dotfiles/nix/pkgs.nix"
        "$HOME/dotfiles/nix/modules/shell.nix"
        "$HOME/dotfiles/nix/modules/zsh.nix"
        "$HOME/dotfiles/nix/modules/darwin.nix"
        "$HOME/dotfiles/nix/modules/vscode.nix"
        "$HOME/dotfiles/nix/modules/neovim.nix"
        "$HOME/dotfiles/nix/modules/aerospace.nix"
        "$HOME/dotfiles/nix/modules/window_manager.nix"
        "$HOME/dotfiles/zsh/cockpit_logic.zsh"
        "$HOME/dotfiles/restore.sh"
        "$HOME/.zshrc"
    )

    # Functionsディレクトリの中身も全て追加（もしあれば）
    for f in "$HOME/dotfiles/zsh/functions/"*.zsh; do
        [ -f "$f" ] && files+=("$f")
    done

    for f in "${files[@]}"; do
        if [ -f "$f" ]; then
            echo ">>> FILE: $f"
            cat "$f"
            echo -e "\n<<< END OF FILE\n"
        else
            echo ">>> FILE: $f (NOT FOUND)"
            echo ""
        fi
    done

} > "$outfile"

echo "✅ Dump Complete: $outfile"
