#!/bin/bash

# 出力先 (デスクトップ)
OUTPUT="$HOME/Desktop/cockpit_full_dump.txt"
TARGET_DIR="$HOME/dotfiles"

echo "# 🚀 COCKPIT SYSTEM FULL DUMP" > "$OUTPUT"
echo "# Generated at: $(date)" >> "$OUTPUT"
echo "# User: $(whoami)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "🔍 Collecting configuration files..."

# findコマンドで特定の拡張子を持つファイルだけを探す (.gitなどは除外)
find "$TARGET_DIR" -type f \
    \( -name "*.zsh" \
    -o -name "*.nix" \
    -o -name "*.sh" \
    -o -name "*.toml" \
    -o -name "*.kdl" \
    -o -name "*.txt" \
    -o -name "*.md" \
    -o -name "*.json" \) \
    -not -path "*/.git/*" \
    -not -name "flake.lock" \
    -not -name ".DS_Store" \
    | sort | while read -r file; do
    
    # ファイルパスを表示 (ホームディレクトリからの相対パス)
    REL_PATH="${file#$HOME/}"
    
    echo "Processing: $REL_PATH"
    
    # 出力ファイルに書き込み
    echo "" >> "$OUTPUT"
    echo "################################################################################" >> "$OUTPUT"
    echo "📂 FILE: $REL_PATH" >> "$OUTPUT"
    echo "################################################################################" >> "$OUTPUT"
    cat "$file" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
done

echo ""
echo "✅ Done! All files merged into: $OUTPUT"
echo "👉 You can now upload this file to AI."
