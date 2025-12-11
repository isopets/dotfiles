#!/bin/bash
OUTPUT_FILE="$HOME/Desktop/cockpit_full_dump.txt"

{
    echo "=========================================="
    echo "🤖 COCKPIT SYSTEM DUMP"
    echo "=========================================="
    echo ""

    echo "--- [1] .zshrc ---"
    cat ~/.zshrc 2>/dev/null || echo "Not Found"
    echo -e "\n\n"

    echo "--- [2] productivity_plus.zsh ---"
    cat ~/dotfiles/zsh/src/productivity_plus.zsh 2>/dev/null || echo "Not Found"
    echo -e "\n\n"

    echo "--- [3] aliases.zsh ---"
    cat ~/dotfiles/zsh/src/aliases.zsh 2>/dev/null || echo "Not Found"
    echo -e "\n\n"
    
} > "$OUTPUT_FILE"

# クリップボードにコピー
pbcopy < "$OUTPUT_FILE"
echo "✅ Copied to clipboard!"
