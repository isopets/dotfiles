function mkproj() {
    if [ -z "$1" ] || [ -z "$2" ]; then echo "❌ Usage: mkproj <Category> <Name>"; return 1; fi
    local c="$1"; local n="$2"; local code="$REAL_CODE_DIR/$c/$n"; local asset="$REAL_ASSETS_DIR/$c/$n"; local para="$PARA_DIR/1_Projects/$n"
    mkdir -p "$code/.vscode" "$asset"/{Design,Video,Export} "$para"
    ln -s "$asset" "$code/_GoToCreative"; ln -s "$code" "$asset/_GoToCode"
    ln -s "$code" "$para/💻_Code"; ln -s "$asset" "$para/🎨_Assets"
    git -C "$code" init; echo "# $n" > "$code/README.md"
    touch "$code/.env"; echo "dotenv" > "$code/.envrc"; echo ".env" >> "$code/.gitignore"; echo ".envrc" >> "$code/.gitignore"
    local tpl="$HOME/dotfiles/templates/vscode/$c.txt"; local exts_json="[]"
    if [ -f "$tpl" ]; then exts_json=$(cat "$tpl" | jq -R . | jq -s .); fi
    [ "$exts_json" != "[]" ] && echo "{ \"recommendations\": $exts_json }" > "$code/.vscode/extensions.json"
    git -C "$code" add .; git -C "$code" commit -m "feat: Init"; echo "✨ Created!"; cd "$code"; if command -v direnv &>/dev/null; then direnv allow .; fi
}
function work() {
    local n="$1"; if [ -z "$1" ]; then n=$(ls "$PARA_DIR/1_Projects" | fzf --prompt="🚀 Launch > "); [ -z "$n" ] && return 1; fi
    local p="$PARA_DIR/1_Projects/$n"; local r=$(readlink "$p/💻_Code")
    if [ -d "$r" ]; then
        echo "🚀 Launching: $n"; mkdir -p "$r/docs"; local log="$r/docs/DEV_LOG.md"; [ ! -f "$log" ] && echo "# Dev Log" > "$log"
        echo "\n## $(date '+%Y-%m-%d %H:%M')" >> "$log"
        cd "$r"; [ -d "$p/🎨_Assets" ] && open "$p/🎨_Assets"
        code --wait "$r" "$log"
        echo "🤖 Auto-Saving..."
        if [ -n "$GEMINI_API_KEY" ]; then local gl=$(git log --since="midnight" --oneline); local gd=$(git diff HEAD); if [ -n "$gl" ] || [ -n "$gd" ]; then local p="Summarize work for log:\nLog:\n$gl\nDiff:\n$gd"; local res=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$p\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text'); echo "$res" >> "$log"; git add .; git commit -m "chore: Auto-save session"; git push; echo "✅ Saved."; fi; fi
    fi
}
function done() {
    local log="./docs/DEV_LOG.md"; [ ! -d ".git" ] && return 1
    if [ -n "$GEMINI_API_KEY" ]; then
        local gl=$(git log --since="midnight" --oneline); local gd=$(git diff HEAD)
        if [ -n "$gl" ] || [ -n "$gd" ]; then
            local p="GitログとDiffから日報を作成して。\nFormat:\n- [DONE] 作業要約\n- [NEXT] 次のタスク案\n\nLog:\n$gl\nDiff:\n$gd"
            local res=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$(echo $p | sed 's/"/\\"/g')\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text')
            echo "$res" >> "$log"
        else echo "- [DONE] (Manual entry)" >> "$log"; fi
    else echo "- [DONE] (Manual entry)" >> "$log"; fi
    code --wait "$log"; git add .; git commit -m "chore: Update log"; git push; echo "🎉 Complete!"
}
function scratch() { local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🐍 Profile > "); [ -n "$p" ] && code --profile "$p"; }
function archive() { local n="$1"; if [ -z "$1" ]; then n=$(ls "$PARA_DIR/1_Projects" | fzf --prompt="📦 Archive > "); [ -z "$n" ] && return 1; fi; mv "$PARA_DIR/1_Projects/$n" "$PARA_DIR/4_Archives/$n"; echo "📦 Archived."; }
function map() { echo "📍 PARA:"; eza --tree --level=2 --icons "$HOME/PARA"; echo "📦 Projects:"; eza --tree --level=2 --icons "$HOME/Projects"; }
function jump() { local c=$(pwd); local t=""; if [[ "$c" == *"/Projects/"* ]]; then t="${c/Projects/Creative}"; else t="${c/Creative/Projects}"; fi; if [ -d "$t" ]; then cd "$t"; echo "🚀 Jumped!"; eza --icons; else echo "⚠️ Target not found."; fi; }
