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
    # ツリー表示 (ezaがあれば使い、なければfind)
    if command -v eza >/dev/null; then
        eza --tree --level=4 -a -I ".git|node_modules|.DS_Store|.cache" "$HOME/dotfiles"
    else
        find "$HOME/dotfiles" -maxdepth 4 -not -path '*/.*'
    fi
    echo ""

    echo "--- FILE CONTENTS ---"
    
    # .nix, .zsh, .sh, .zshrc, flake.lock を全て収集
    find "$HOME/dotfiles" -type f \( -name "*.nix" -o -name "*.zsh" -o -name "*.sh" -o -name ".zshrc" -o -name "flake.lock" \) -not -path "*/.git/*" | sort | while read f; do
        echo ">>> FILE: $f"
        cat "$f"
        echo -e "\n<<< END OF FILE\n"
    done

} > "$outfile"

echo "✅ Dump Complete: $outfile"
