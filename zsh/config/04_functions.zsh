# =================================================================
# 🛠️ Helper Functions (The Core - AI & Automation)
# =================================================================
export REAL_CODE_DIR="$HOME/Projects"
export REAL_ASSETS_DIR="$HOME/Creative"
export PARA_DIR="$HOME/PARA"
export VSCODE_SNAPSHOT_DIR="$HOME/dotfiles/vscode/.snapshots"

# --- 1. Dashboard ---
function dev() {
    local selected=$(cat <<END | fzf --prompt="🔥 Dev Menu > " --height=50% --layout=reverse --border
🚀 Start Work       (work)        : プロジェクトを開く
✨ New Project      (mkproj)      : 新規プロジェクト作成
🏁 Finish Work      (done)        : 日報作成＆終了 (AI)
📝 Scratchpad       (scratch)     : 空のVS Codeを起動
---------------------------------
📦 Archive Project  (archive)     : プロジェクトをアーカイブ
🗺️  Show Map         (map)         : 環境の全体像を表示
---------------------------------
🐍 VS Code Profile  (mkprofile)   : プロファイル作成
🗑️ Delete Profile   (rmprofile)   : プロファイル削除
⚙️ Apply & Lock     (update-vscode): 設定変更を反映
🔓 Unlock Settings  (unlock-vscode): 設定変更のためにロック解除
🧪 Trial Mode       (trial-start) : 試着モード開始
🛍️ Pick & Commit    (trial-pick)  : 試着した拡張機能を選んで採用
🕰️ History/Restore  (history-vscode): バックアップから復元
---------------------------------
🤖 Ask AI           (ask)         : AIに質問
💬 Commit Msg       (gcm)         : コミットメッセージ生成
🔑 Bitwarden Env    (bwfzf)       : APIキー注入
🌐 Chrome Sync      (chrome-sync) : 拡張機能取り込み
📖 Read Manual      (rules)       : ルール確認
🔄 Reload Shell     (sz)          : 再読み込み
END
    )
    case "$selected" in
        *"Start Work"*) work ;;
        *"New Project"*) echo -n "📂 Cat: "; read c; echo -n "📛 Name: "; read n; mkproj "$c" "$n" ;;
        *"Finish Work"*) done ;;
        *"Scratchpad"*) scratch ;;
        *"Archive Project"*) archive ;;
        *"VS Code Profile"*) mkprofile ;;
        *"Delete Profile"*) rmprofile ;;
        *"Apply & Lock"*) safe-update ;;
        *"Unlock Settings"*) unlock-vscode ;;
        *"Trial Mode"*) safe-trial ;;
        *"Pick & Commit"*) trial-pick ;;
        *"History/Restore"*) history-vscode ;;
        *"Ask AI"*) echo -n "❓ Q: "; read q; ask "$q" ;;
        *"Commit Msg"*) gcm ;;
        *"Bitwarden Env"*) echo -n "📝 Var: "; read k; bwfzf "$k" ;;
        *"Chrome Sync"*) ~/dotfiles/chrome/sync_chrome_extensions.sh ;;
        *"Read Manual"*) rules ;;
        *"Reload Shell"*) sz ;;
        *) echo "👋 Canceled." ;;
    esac
}

# --- 2. AI Auto-Fix Hook ---
function precmd() {
    local exit_code=$?
    if [ $exit_code -eq 0 ] || [ $exit_code -eq 130 ]; then return; fi
    if [ -z "$GEMINI_API_KEY" ]; then return; fi
    local last_cmd=$(fc -ln -1)
    if [[ ${#last_cmd} -lt 4 ]] || [[ "$last_cmd" == "cd"* ]]; then return; fi
    if [[ "$TERM_PROGRAM" == "Warp.app" ]]; then return; fi

    echo "\n🤖 Command failed. Asking Gemini..."
    local fix=$(curl -s -H "Content-Type: application/json" \
      -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Fix this zsh command error. Output ONLY the corrected command string, no markdown.\nCommand: $last_cmd\" }] }] }" \
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
      | jq -r '.candidates[0].content.parts[0].text' | sed 's/`//g' | xargs)
    if [ -n "$fix" ] && [ "$fix" != "null" ]; then
        echo "💡 Suggestion: \033[1;32m$fix\033[0m"
        print -z "$fix"
    fi
}

# --- 3. Project Management (Auto-Log & AI) ---
function work() {
    local n="$1"
    if [ -z "$1" ]; then n=$(ls "$PARA_DIR/1_Projects" | fzf --prompt="🚀 Launch > "); [ -z "$n" ] && return 1; fi
    local path="$PARA_DIR/1_Projects/$n"
    
    if [ -d "$path/💻_Code" ]; then
        local real=$(readlink "$path/💻_Code")
        mkdir -p "$real/docs"
        local log="$real/docs/DEV_LOG.md"
        [ ! -f "$log" ] && echo "# Dev Log: $n" > "$log"

        echo "🤖 Analyzing logs..."
        local prev=$(tail -n 20 "$log")
        local sug=""
        if [ -n "$GEMINI_API_KEY" ] && [ -n "$prev" ]; then
            sug=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"以下の開発ログの最後を見て、次に着手すべきタスクを『・』から始まる1行のTODOで提案せよ。挨拶不要。\n\n$prev\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text')
        fi
        
        echo "\n## $(date '+%Y-%m-%d %H:%M') ------------------" >> "$log"
        [ -n "$sug" ] && echo "$sug" >> "$log" || echo "- " >> "$log"

        code "$real"; code "$log" --goto $(wc -l < "$log"):3
        cd "$real"
        
        # Expert Mode check
        if [ ! -f "$HOME/.dotfiles_expert_mode" ]; then
            (sleep 1; code "$HOME/dotfiles/docs/WORKFLOW.md" && code --command markdown.showPreview) &
        fi
    fi
    [ -d "$path/🎨_Assets" ] && open "$path/🎨_Assets"
    echo "✅ Ready."
}

function done() {
    local log="./docs/DEV_LOG.md"
    if [ ! -d ".git" ] || [ ! -f "$log" ]; then echo "❌ Not in a project."; return 1; fi
    echo "🤖 Generating report..."
    local gl=$(git log --since="midnight" --oneline); local gd=$(git diff HEAD)
    if [ -z "$gl" ] && [ -z "$gd" ]; then echo "🤔 No work today."; return; fi

    if [ -n "$GEMINI_API_KEY" ]; then
        local p="GitログとDiffから日報を作成して。\nFormat:\n- [DONE] 作業要約\n- [NEXT] 次のタスク案\n\nLog:\n$gl\nDiff:\n$gd"
        local res=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$(echo $p | sed 's/"/\\"/g')\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text')
        echo "$res" >> "$log"
    else
        echo "- [DONE] (Manual entry)" >> "$log"
    fi
    
    code --wait "$log"
    echo "📦 Saving..."
    git add .
    git commit -m "chore: Update dev log"
    git push
    echo "🎉 Complete!"
}

# --- 4. VS Code Management ---
function mkprofile() {
    local vd="$HOME/dotfiles/vscode"; echo -n "📛 Name: "; read n; [ -z "$n" ] && return 1
    local pn="[Lang] $n"; local fn="$(echo "$n"|tr '[:upper:]' '[:lower:]').json"; local fp="$vd/source/$fn"
    if [ ! -f "$fp" ]; then echo "{}" > "$fp"; fi
    if ! grep -q "$pn" "$vd/profile_list.txt"; then echo "$pn:$fn" >> "$vd/profile_list.txt"; fi
    "$vd/update_settings.sh" >/dev/null; "$HOME/dotfiles/setup.sh" >/dev/null
    chmod +w "$HOME/Library/Application Support/Code/User/profiles/$pn/settings.json"
    echo "🚀 Launching..."; code --profile "$pn" .
}
function rmprofile() {
    local list="$HOME/dotfiles/vscode/profile_list.txt"; local sel=$(grep -v "\[Base\] Common" "$list" | fzf --prompt="🗑️ Delete > "); [ -z "$sel" ] && return 1
    local name=$(echo "$sel"|cut -d: -f1); local file=$(echo "$sel"|cut -d: -f2)
    echo "🚨 Delete '$name'? (y/n)"; read c; [ "$c" != "y" ] && return 1
    gsed -i "/$name/d" "$list"; rm -f "$HOME/dotfiles/vscode/source/$file"
    "$HOME/dotfiles/vscode/update_settings.sh" >/dev/null; "$HOME/dotfiles/setup.sh" >/dev/null
    rm -rf "$HOME/Library/Application Support/Code/User/profiles/$name"; echo "✨ Deleted."
}
function unlock-vscode() { find "$HOME/Library/Application Support/Code/User/profiles" -name "settings.json" -exec chmod +w {} \;; echo "🔓 Unlocked!"; }
function diff-vscode() { local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🔍 Diff > "); [ -n "$p" ] && bat "$HOME/Library/Application Support/Code/User/profiles/$p/settings.json" -l json; }

function take_snapshot() {
    local p="$1"; local r="$2"; local ts=$(date "+%Y-%m-%d_%H-%M-%S")
    local td="$VSCODE_SNAPSHOT_DIR/$p/$ts-$r"; local src="$HOME/Library/Application Support/Code/User/profiles/$p/settings.json"
    if [ -f "$src" ]; then mkdir -p "$td"; cp "$src" "$td/settings.json"; code --list-extensions | sort > "$td/extensions.list"; echo "📸 Saved: $ts"; fi
}
function safe-update() {
    echo "🛑 Locking settings..."; echo -n "Run? (y/n): "; read c; [ "$c" != "y" ] && return 1
    while IFS=: read -r n f; do [[ "$n" =~ ^[^#] && -n "$n" ]] && take_snapshot "$n" "Pre-Lock"; done < "$HOME/dotfiles/vscode/profile_list.txt"
    update-vscode; echo "🔒 Locked."
}
function safe-trial() { trial-start; }
function trial-start() {
    local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🧪 Trial > "); [ -z "$p" ] && return 1
    take_snapshot "$p" "Trial-Start"
    local s="$HOME/Library/Application Support/Code/User/profiles/$p/settings.json"; chmod +w "$s"; echo "🧪 Started for $p"
}
function trial-reset() {
    local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="↩️ Revert > "); [ -z "$p" ] && return 1
    local sd="$VSCODE_SNAPSHOT_DIR/$p"; local ls=$(ls "$sd" | grep "Trial-Start" | sort -r | head -n 1)
    [ -z "$ls" ] && { echo "❌ No backup."; return 1; }
    local src="$sd/$ls"; local dst="$HOME/Library/Application Support/Code/User/profiles/$p/settings.json"
    cp "$src/settings.json" "$dst"
    local curr=$(mktemp); code --list-extensions|sort > "$curr"; local new=$(comm -13 "$src/extensions.list" "$curr")
    [ -n "$new" ] && echo "$new" | while read e; do code --uninstall-extension "$e"; done
    rm "$curr"; ~/dotfiles/vscode/update_settings.sh >/dev/null; ~/dotfiles/setup.sh >/dev/null
    echo "✨ Reset."
}
function trial-pick() {
    local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🛍️ Pick > "); [ -z "$p" ] && return 1
    local bd="$HOME/dotfiles/vscode/.backup/$p"; [ ! -f "$bd/extensions.list.bak" ] && { echo "❌ No backup."; return 1; }
    local c=$(mktemp); code --list-extensions|sort > "$c"; local n=$(comm -13 "$bd/extensions.list.bak" "$c")
    if [ -n "$n" ]; then
        local sel=$(echo "$n" | fzf -m --prompt="Keep > " --preview "echo {}"); 
        if [ -n "$sel" ]; then echo "$sel" >> "$HOME/dotfiles/vscode/install_extensions.sh"; fi
        echo "$n" | while read e; do if ! echo "$sel" | grep -q "$e"; then code --uninstall-extension "$e"; fi; done
    fi
    rm "$c"; diff-vscode "$p"; echo "Edit JSON then Enter."; read; safe-update; take_snapshot "$p" "Post-Pick"
}
function history-vscode() {
    local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🕰️ Profile > "); [ -z "$p" ] && return 1
    local snap=$(ls "$VSCODE_SNAPSHOT_DIR/$p" | sort -r | fzf --prompt="Restore > "); [ -z "$snap" ] && return 1
    local src="$VSCODE_SNAPSHOT_DIR/$p/$snap"; cp "$src/settings.json" "$HOME/Library/Application Support/Code/User/profiles/$p/settings.json"
    cat "$src/extensions.list" | while read e; do code --install-extension "$e"; done
    echo "✨ Restored."
}

# --- 5. Common Utilities ---
function mkproj() {
    if [ -z "$1" ] || [ -z "$2" ]; then echo "❌ Usage: mkproj <Category> <Name>"; return 1; fi
    local c="$1"; local n="$2"; local code="$REAL_CODE_DIR/$c/$n"; local asset="$REAL_ASSETS_DIR/$c/$n"; local para="$PARA_DIR/1_Projects/$n"
    mkdir -p "$code/.vscode" "$asset"/{Design,Video,Export} "$para"
    ln -s "$asset" "$code/_GoToCreative"; ln -s "$code" "$asset/_GoToCode"
    ln -s "$code" "$para/💻_Code"; ln -s "$asset" "$para/🎨_Assets"
    
    # .clinerules (CLIルール)
    cat <<R > "$code/.clinerules"
1. VS Code Settings: Use CLI (edit-vscode, update-vscode). DO NOT edit GUI.
2. File Structure: Code=./, Assets=./_GoToCreative
3. Security: Use .env and direnv. No raw keys.
R
    
    touch "$code/.env"; echo "dotenv" > "$code/.envrc"; echo ".env" >> "$code/.gitignore"; echo ".envrc" >> "$code/.gitignore"
    git -C "$code" init; echo "# $n" > "$code/README.md"; git -C "$code" add .; git -C "$code" commit -m "feat: Init"
    echo "✨ Created!"; cd "$code"; if command -v direnv &>/dev/null; then direnv allow .; fi
}

function archive() {
    local n="$1"; if [ -z "$1" ]; then n=$(ls "$PARA_DIR/1_Projects" | fzf --prompt="📦 Archive > "); [ -z "$n" ] && return 1; fi
    mv "$PARA_DIR/1_Projects/$n" "$PARA_DIR/4_Archives/$n"; echo "📦 Archived."
}
function map() { echo "📍 PARA:"; eza --tree --level=2 --icons "$HOME/PARA"; }
function ask() {
    [ -z "$GEMINI_API_KEY" ] && { echo "❌ No Key."; return 1; }
    local r=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Command only: $1\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY");
    echo "$r" | jq -r '.candidates[0].content.parts[0].text';
}
function gcm() {
    [ -z "$GEMINI_API_KEY" ] && return 1; local d=$(git diff --cached); [ -z "$d" ] && return 1
    local m=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Git commit message for:\n$d\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text')
    echo "$m"; read -r -p "Commit? (y/n): " c; [ "$c" = "y" ] && git commit -m "$m"
}
function bwenv() { local p=$(bw get password "$1"); echo "$2=$p" >> .env; echo "✅ Added."; }
function bwfzf() { local i=$(bw list items --search "" | jq -r '.[].name' | fzf --prompt="Select Item > "); [ -n "$i" ] && bwenv "$i" "$1"; }
function ali() { local s=$(alias|fzf|cut -d'=' -f1); [ -n "$s" ] && print -z "$s"; }
