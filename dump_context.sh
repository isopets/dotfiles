#!/bin/bash
timestamp=$(date "+%Y%m%d_%H%M%S")
outfile="$HOME/Desktop/cockpit_dump_${timestamp}.txt"

echo "📦 Dumping Cockpit Context (Modular) to: $outfile"

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
    
    # 1. Nix Core Files
    files=(
        "$HOME/dotfiles/flake.nix"
        "$HOME/dotfiles/home.nix"
        "$HOME/dotfiles/nix/pkgs.nix"
    )
    
    # 2. Nix Modules
    for f in "$HOME/dotfiles/nix/modules/"*.nix; do
        [ -f "$f" ] && files+=("$f")
    done

    # 3. Zsh Logic Modules (src) 🚨 ここを修正
    # cockpit_logic.zsh ではなく、src フォルダの中身を正とする
    for f in "$HOME/dotfiles/zsh/src/"*.zsh; do
        [ -f "$f" ] && files+=("$f")
    done

    # 4. Other Configs
    files+=(
        "$HOME/dotfiles/restore.sh"
        "$HOME/.zshrc"
    )

    # 出力実行
    for f in "${files[@]}"; do
        if [ -f "$f" ]; then
            echo ">>> FILE: $f"
            cat "$f"
            echo -e "\n<<< END OF FILE\n"
        else
            # 存在しないファイルは無視（ノイズになるため出力しない）
            : 
        fi
    done

} > "$outfile"

echo "✅ Dump Complete: $outfile"
