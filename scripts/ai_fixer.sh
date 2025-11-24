#!/bin/bash
# Usage: fix-it <broken_file>

FILE="$1"
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then echo "❌ File not found."; exit 1; fi
if [ -z "$GEMINI_API_KEY" ]; then echo "❌ API Key missing."; exit 1; fi

echo "🚑 Asking AI to fix syntax errors in: $FILE ..."

# ファイルの中身を読む
CONTENT=$(cat "$FILE")

# AIへのプロンプト
PROMPT="You are a Zsh expert. The following zsh script has syntax errors (parse errors).
Fix ONLY the syntax errors (missing brackets, unclosed quotes, bad loops).
Do NOT change the logic.
Output ONLY the fixed code block, no markdown, no explanation.

--- CODE ---
$CONTENT"

# Gemini API呼び出し
FIXED_CODE=$(curl -s -H "Content-Type: application/json" \
    -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$(echo $PROMPT | sed 's/"/\\"/g')\" }] }] }" \
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
    | jq -r '.candidates[0].content.parts[0].text' | sed 's/^```zsh//' | sed 's/^```bash//' | sed 's/^```//' | sed 's/```$//')

if [ -z "$FIXED_CODE" ] || [ "$FIXED_CODE" == "null" ]; then
    echo "❌ AI failed to fix the code."
    exit 1
fi

# 修正版を一時ファイルに保存してチェック
TEMP=$(mktemp)
echo "$FIXED_CODE" > "$TEMP"

if zsh -n "$TEMP"; then
    mv "$TEMP" "$FILE"
    echo "✨ Fixed & Saved! ($FILE)"
    echo "🔄 Reloading..."
    source ~/.zshrc
else
    echo "⚠️ AI's fix was also broken. Opening manually..."
    rm "$TEMP"
    code "$FILE"
fi
