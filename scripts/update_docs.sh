#!/bin/bash

# 設定
FUNC_FILE="$HOME/dotfiles/zsh/config/04_functions.zsh"
DOC_FILE="$HOME/dotfiles/docs/WORKFLOW.md"
TEMP_DOC=$(mktemp)

echo "📝 Updating WORKFLOW.md from functions..."

# 1. 既存のマニュアルから「自動生成エリア」より前を保持する
# (もし "## 🤖 自動生成..." という行がなければ全文保持、あればそこまでを切り出す)
if grep -q "## 🤖 自動生成コマンド一覧" "$DOC_FILE"; then
    sed '/## 🤖 自動生成コマンド一覧/q' "$DOC_FILE" | head -n -1 > "$TEMP_DOC"
else
    cat "$DOC_FILE" > "$TEMP_DOC"
    echo "" >> "$TEMP_DOC"
fi

# 2. ヘッダー追記
echo "## 🤖 自動生成コマンド一覧 (Auto-Generated)" >> "$TEMP_DOC"
echo "| コマンド | 説明 |" >> "$TEMP_DOC"
echo "| :--- | :--- |" >> "$TEMP_DOC"

# 3. 関数解析
# (直前の行が # で始まっていたら説明として取得)
grep -B 1 "^function " "$FUNC_FILE" | while read line; do
    # コメント行の処理
    if [[ "$line" =~ ^# ]]; then
        DESC=$(echo "$line" | sed 's/^# //')
    fi
    
    # 関数定義行の処理
    if [[ "$line" =~ ^function ]]; then
        CMD=$(echo "$line" | awk '{print $2}' | sed 's/()//')
        
        # 説明文が取得できていれば書き込み
        if [ -n "$DESC" ]; then
            echo "| **\`$CMD\`** | $DESC |" >> "$TEMP_DOC"
            DESC="" # リセット
        fi
    fi
done

# 4. 上書き保存
mv "$TEMP_DOC" "$DOC_FILE"
echo "✅ WORKFLOW.md updated."

# 5. navi更新
if [ -f "$HOME/dotfiles/scripts/generate_cheatsheet.sh" ]; then
    "$HOME/dotfiles/scripts/generate_cheatsheet.sh" > /dev/null
fi
