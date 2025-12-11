#!/bin/bash
OUTPUT_FILE="$HOME/Desktop/cockpit_full_dump.txt"

{
    echo "=========================================="
    echo "🤖 COCKPIT FULL SYSTEM DUMP ($(date))"
    echo "=========================================="
    echo ""

    echo "--- 📂 Directory Structure (フォルダ構造) ---"
    # .git などを除外してツリー表示風に出力
    find ~/dotfiles -maxdepth 4 -not -path '*/.*' | sort | sed -e "s|^$HOME/dotfiles|~/dotfiles|"
    echo ""
    echo "=========================================="
    echo ""

    # 1. External Config (dotfilesの外にある重要ファイル)
    echo "=========================================="
    echo "--- [FILE] ~/.zshrc ---"
    echo "=========================================="
    cat ~/.zshrc 2>/dev/null || echo "(Not Found)"
    echo -e "\n\n"

    # 2. Internal Configs (dotfiles内の全ファイル)
    # .git, .DS_Store, 画像ファイルなどを除外してループ処理
    find ~/dotfiles -type f \
        -not -path '*/.git/*' \
        -not -name '.DS_Store' \
        -not -name '*.png' \
        -not -name '*.jpg' \
        | sort | while read -r file; do
        
        # ファイルパスを見やすく整形
        display_path=$(echo "$file" | sed "s|$HOME|~|")
        
        echo "=========================================="
        echo "--- [FILE] $display_path ---"
        echo "=========================================="
        
        # 中身を出力 (空ファイルならEmptyと表示)
        if [ -s "$file" ]; then
            cat "$file"
        else
            echo "(Empty File)"
        fi
        echo -e "\n\n"
    done

} > "$OUTPUT_FILE"

# クリップボードにコピー
pbcopy < "$OUTPUT_FILE"
echo "✅ Full Dump created: $OUTPUT_FILE"
echo "📋 Copied to clipboard! Ready to paste."