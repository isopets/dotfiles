# プロジェクト作成 (mkproj)
function mkproj() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "❌ Usage: mkproj <Category> <Name>"
        return 1
    fi
    local c="$1"; local n="$2"
    local code="$REAL_CODE_DIR/$c/$n"
    local asset="$REAL_ASSETS_DIR/$c/$n"
    local para="$PARA_DIR/1_Projects/$n"

    mkdir -p "$code/.vscode"
    mkdir -p "$asset"/{Design,Video,Export}
    mkdir -p "$para"

    ln -s "$asset" "$code/_GoToCreative"
    ln -s "$code" "$asset/_GoToCode"
    ln -s "$code" "$para/💻_Code"
    ln -s "$asset" "$para/🎨_Assets"
    
    git -C "$code" init
    echo "# $n" > "$code/README.md"
    touch "$code/.env"; echo "dotenv" > "$code/.envrc"
    echo ".env" >> "$code/.gitignore"; echo ".envrc" >> "$code/.gitignore"
    
    # 推奨拡張機能の自動設定
    local tpl="$HOME/dotfiles/templates/vscode/$c.txt"
    local exts_json="[]"
    if [ -f "$tpl" ]; then
        exts_json=$(cat "$tpl" | jq -R . | jq -s .)
    fi
    if [ "$exts_json" != "[]" ]; then
        echo "{ \"recommendations\": $exts_json }" > "$code/.vscode/extensions.json"
    fi

    git -C "$code" add .
    git -C "$code" commit -m "feat: Init"

    echo "✨ Created!"; cd "$code"; if command -v direnv &>/dev/null; then direnv allow .; fi
}

# 作業開始 (work)
function work() {
    local n="$1"
    if [ -z "$1" ]; then
        n=$(ls "$PARA_DIR/1_Projects" | fzf --prompt="🚀 Launch > ")
        if [ -z "$n" ]; then return 1; fi
    fi
    local p="$PARA_DIR/1_Projects/$n"
    local r=$(readlink "$p/💻_Code")
    
    if [ -d "$r" ]; then
        echo "🚀 Launching: $n"
        mkdir -p "$r/docs"
        local log="$r/docs/DEV_LOG.md"
        if [ ! -f "$log" ]; then echo "# Dev Log" > "$log"; fi
        
        echo "\n## $(date '+%Y-%m-%d %H:%M')" >> "$log"
        
        cd "$r"
        if [ -d "$p/🎨_Assets" ]; then open "$p/🎨_Assets"; fi
        
        # VS Codeを開いて閉じるまで待機
        code --wait "$r" "$log"
        
        # 閉じた後の自動保存処理
        echo "🤖 Auto-Saving..."
        if [ -n "$GEMINI_API_KEY" ]; then
            local gl=$(git log --since="midnight" --oneline)
            local gd=$(git diff HEAD)
            if [ -n "$gl" ] || [ -n "$gd" ]; then
                local prompt="Summarize work for log:\nLog:\n$gl\nDiff:\n$gd"
                local res=$(curl -s -H "Content-Type: application/json" \
                    -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$prompt\" }] }] }" \
                    "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
                    | jq -r '.candidates[0].content.parts[0].text')
                echo "$res" >> "$log"
                git add .
                git commit -m "chore: Auto-save session"
                git push
                echo "✅ Saved."
            fi
        fi
    fi
}

# 作業終了 (finish-work)
function finish-work() {
    local log="./docs/DEV_LOG.md"
    if [ ! -d ".git" ] || [ ! -f "$log" ]; then echo "❌ Not in project."; return 1; fi
    
    local gl=$(git log --since="midnight" --oneline)
    local gd=$(git diff HEAD)
    
    if [ -n "$GEMINI_API_KEY" ]; then
        local p="GitログとDiffから日報を作成して。\nFormat:\n- [DONE] 作業要約\n- [NEXT] 次のタスク案\n\nLog:\n$gl\nDiff:\n$gd"
        local res=$(curl -s -H "Content-Type: application/json" \
            -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$(echo $p | sed 's/"/\\"/g')\" }] }] }" \
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
            | jq -r '.candidates[0].content.parts[0].text')
        echo "$res" >> "$log"
    else
        echo "- [DONE] (Manual entry)" >> "$log"
    fi
    
    code --wait "$log"
    git add .
    git commit -m "chore: Update log"
    git push
    echo "🎉 Complete!"
}
alias done="finish-work"

function scratch() {
    local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🐍 Profile > ")
    if [ -n "$p" ]; then code --profile "$p"; fi
}

function archive() {
    local n="$1"
    if [ -z "$1" ]; then
        n=$(ls "$PARA_DIR/1_Projects" | fzf --prompt="📦 Archive > ")
        if [ -z "$n" ]; then return 1; fi
    fi
    mv "$PARA_DIR/1_Projects/$n" "$PARA_DIR/4_Archives/$n"
    echo "📦 Archived."
}

function map() {
    echo "\n📍 PARA:"
    eza --tree --level=2 --icons "$HOME/PARA"
    echo "\n📦 Projects:"
    eza --tree --level=2 --icons "$HOME/Projects"
}

function jump() {
    local c=$(pwd); local t=""
    if [[ "$c" == *"/Projects/"* ]]; then
        t="${c/Projects/Creative}"
    elif [[ "$c" == *"/Creative/"* ]]; then
        t="${c/Creative/Projects}"
    else
        echo "❌ Not in project."
        return 1
    fi
    if [ -d "$t" ]; then
        cd "$t"; echo "🚀 Jumped!"; eza --icons
    else
        echo "⚠️ Target not found."
    fi
}
