function mkproj() {
    if [ -z "$1" ] || [ -z "$2" ]; then echo "❌ Usage: mkproj <Category> <Name>"; return 1; fi
    local c="$1"; local n="$2"; local p="$REAL_CODE_DIR/$c/$n"
    local a="$REAL_ASSETS_DIR/$c/$n"; local para="$PARA_DIR/1_Projects/$n"

    mkdir -p "$p/.vscode"
    mkdir -p "$a"/{Design,Video,Export}
    mkdir -p "$para"

    ln -s "$a" "$p/_GoToCreative"
    ln -s "$p" "$a/_GoToCode"
    ln -s "$p" "$para/💻_Code"
    ln -s "$a" "$para/🎨_Assets"

    git -C "$p" init
    echo "# $n" > "$p/README.md"
    touch "$p/.env"
    echo "dotenv" > "$p/.envrc"
    echo ".env" >> "$p/.gitignore"
    echo ".envrc" >> "$p/.gitignore"

    # AI or Preset for Extensions
    local tpl="$HOME/dotfiles/templates/vscode/$c.txt"
    local exts_json="[]"
    if [ -f "$tpl" ]; then
        exts_json=$(cat "$tpl" | jq -R . | jq -s .)
    elif [ -n "$GEMINI_API_KEY" ]; then
        echo "🤖 Asking AI for recommended extensions..."
        local prompt="List 5 essential VS Code extension IDs for '$c' development. Output IDs only."
        local res=$(curl -s -H "Content-Type: application/json" \
            -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$prompt\" }] }] }" \
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
            | jq -r '.candidates[0].content.parts[0].text' | sed 's/`//g')
        if [ -n "$res" ]; then
            exts_json=$(echo "$res" | jq -R . | jq -s .)
        fi
    fi
    
    if [ "$exts_json" != "[]" ]; then
        echo "{ \"recommendations\": $exts_json }" > "$p/.vscode/extensions.json"
    fi

    git -C "$p" add .
    git -C "$p" commit -m "feat: Init"
    
    notify "New Project" "$n created successfully!"
    echo "✨ Created $n"
    cd "$p"; if command -v direnv &>/dev/null; then direnv allow .; fi
}

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
        if [ ! -f "$log" ]; then echo "# Dev Log: $n" > "$log"; fi
        
        echo "\n## $(date '+%Y-%m-%d %H:%M')" >> "$log"
        
        cd "$r"
        if [ -d "$p/🎨_Assets" ]; then open "$p/🎨_Assets"; fi
        
        # VS Codeを開いて閉じるまで待つ
        code --wait "$r" "$log"
        
        echo "🤖 Auto-Saving Session..."
        if [ -n "$GEMINI_API_KEY" ]; then
            local gl=$(git log --since="midnight" --oneline)
            local gd=$(git diff HEAD)
            if [ -n "$gl" ] || [ -n "$gd" ]; then
                local prompt="Summarize work for log based on:\nLog:\n$gl\nDiff:\n$gd"
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

function finish-work() {
    local log="./docs/DEV_LOG.md"
    if [ ! -d ".git" ]; then echo "❌ Not in project."; return 1; fi
    
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
    notify "Work Finished" "Great job!"
    echo "🎉 Complete!"
}
alias done="finish-work"

function scratch() { 
    local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🐍 Profile > ")
    if [ -n "$p" ]; then code --profile "$p"; fi 
}
function archive() { 
    local n="$1"
    if [ -z "$1" ]; then n=$(ls "$PARA_DIR/1_Projects" | fzf --prompt="📦 Archive > "); if [ -z "$n" ]; then return 1; fi; fi
    mv "$PARA_DIR/1_Projects/$n" "$PARA_DIR/4_Archives/$n"
    echo "📦 Archived."
}
function map() { echo "📍 PARA:"; eza --tree --level=2 --icons "$HOME/PARA"; echo "📦 Projects:"; eza --tree --level=2 --icons "$HOME/Projects"; }