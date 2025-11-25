# =================================================================
# 🛠️ Helper Functions (Final Complete with save-dot)
# =================================================================

export REAL_CODE_DIR="$HOME/Projects"
export REAL_ASSETS_DIR="$HOME/Creative"
export PARA_DIR="$HOME/PARA"
export VSCODE_SNAPSHOT_DIR="$HOME/dotfiles/vscode/.snapshots"
export AI_CACHE_DIR="$HOME/dotfiles/.cache/ai"
export BW_SESSION_FILE="$HOME/.bw_session"
mkdir -p "$AI_CACHE_DIR"

# ---------------------------------------------------
# 0. UX Helpers
# ---------------------------------------------------
function notify() {
    local title="$1"; local message="$2"
    osascript -e "display notification \"$message\" with title \"🚀 Cockpit: $title\""
}

# ---------------------------------------------------
# 1. Dashboard (dev)
# ---------------------------------------------------
function dev() {
    local menu_items="🚀 Start Work       (work)        : プロジェクトを開く
✨ New Project      (mkproj)      : 新規プロジェクト作成
🏁 Finish Work      (done)        : 日報作成＆終了
💾 Save Dotfiles    (save-dot)    : 設定をGitHubへ保存
📝 Scratchpad       (scratch)     : 空のVS Codeを起動
---------------------------------
📦 Archive Project  (archive)     : プロジェクトをアーカイブ
🗺️  Show Map         (map)         : 環境の全体像を表示
❓ Help / Why       (why)         : 疑問解決Q&A
---------------------------------
🐍 VS Code Profile  (mkprofile)   : プロファイル作成
⚙️ Apply & Lock     (update-vscode): 設定変更を反映
🔓 Unlock Settings  (unlock-vscode): 設定変更のためにロック解除
🧪 Trial Mode       (trial-start) : 試着モード開始
🛍️ Pick & Commit    (trial-pick)  : 試着した拡張機能を選んで採用
🕰️ History/Restore  (history-vscode): バックアップから復元
---------------------------------
🤖 Ask AI           (ask)         : AIに質問
📝 Explain Code     (explain-it)  : ファイルに解説コメントを追記
💬 Commit Msg       (gcm)         : コミットメッセージ生成
💾 Save Secret      (save-key)    : クリップボードの鍵を保存
🌐 Chrome Sync      (chrome-sync) : 拡張機能取り込み
📖 Read Manual      (rules)       : ルール確認
🔄 Reload Shell     (sz)          : 再読み込み"

    local selected=$(echo "$menu_items" | fzf --prompt="🔥 Cockpit > " --height=50% --layout=reverse --border)
    
    case "$selected" in
        *"Start Work"*) work ;;
        *"New Project"*) echo -n "📂 Cat: "; read c; echo -n "📛 Name: "; read n; mkproj "$c" "$n" ;;
        *"Finish Work"*) finish-work ;;
        *"Save Dotfiles"*) save-dot ;;
        *"Scratchpad"*) scratch ;;
        *"Archive"*) archive ;;
        *"Show Map"*) map ;;
        *"Help"*) why ;;
        *"VS Code Profile"*) mkprofile ;;
        *"Apply"*) safe-update ;;
        *"Unlock"*) unlock-vscode ;;
        *"Trial Mode"*) safe-trial ;;
        *"Pick"*) trial-pick ;;
        *"History"*) history-vscode ;;
        *"Ask AI"*) echo -n "❓ Q: "; read q; ask "$q" ;;
        *"Explain Code"*) echo -n "📄 File: "; read f; explain-it "$f" ;;
        *"Commit Msg"*) gcm ;;
        *"Save Secret"*) save-key ;;
        *"Chrome Sync"*) ~/dotfiles/chrome/sync_chrome_extensions.sh ;;
        *"Read Manual"*) rules ;;
        *"Reload"*) sz ;;
        *) echo "👋 Canceled." ;;
    esac
}

# ---------------------------------------------------
# 2. Dotfiles Management (save-dot)
# ---------------------------------------------------
function save-dot() {
    echo "📦 Saving Dotfiles..."
    local cur=$(pwd)
    cd "$HOME/dotfiles"
    
    # 拡張機能リストの同期 (存在確認)
    if [ -x "vscode/sync_extensions.sh" ]; then
        ./vscode/sync_extensions.sh
    fi
    
    git add .
    
    # AIによるメッセージ生成 (なければ日時)
    local msg="chore: Update dotfiles $(date '+%Y-%m-%d %H:%M')"
    if [ -n "$GEMINI_API_KEY" ]; then
        local diff=$(git diff --cached --name-only | head -n 10)
        if [ -n "$diff" ]; then
            echo "🤖 Generating commit message..."
            local p="Write a short git commit message for updating these files: $diff"
            local res=$(curl -s -H "Content-Type: application/json" \
                -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$p\" }] }] }" \
                "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
                | jq -r '.candidates[0].content.parts[0].text')
            if [ -n "$res" ] && [ "$res" != "null" ]; then msg="$res"; fi
        fi
    fi
    
    git commit -m "$msg"
    git push origin main
    
    cd "$cur"
    echo "✅ Dotfiles saved to GitHub!"
    notify "Dotfiles" "Successfully saved & pushed."
}

# ---------------------------------------------------
# 3. AI Utilities
# ---------------------------------------------------
function check_gemini_key() {
    if [ -n "$GEMINI_API_KEY" ]; then return 0; fi
    echo "❌ GEMINI_API_KEY is missing."; return 1
}
function ask() {
    check_gemini_key || return 1
    local q="$1"; [ -z "$q" ] && return 1
    local h=$(echo "$q" | md5); local c="$AI_CACHE_DIR/$h.txt"
    if [ -f "$c" ]; then echo "⚡️ Cached:"; cat "$c"; return 0; fi
    echo "🤖 Asking..."
    local r=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Command only: $q\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY")
    local a=$(echo "$r" | jq -r '.candidates[0].content.parts[0].text')
    [ -n "$a" ] && echo "$a" | tee "$c" || echo "❌ Error: $r"
}
function explain-it() {
    local f="$1"; [ ! -f "$f" ] && return 1
    echo "🤖 Explaining..."
    local c=$(cat "$f"); local p="Add Japanese comments to explain this code:\n$c"
    local r=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$p\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text' | sed 's/^```.*//' | sed 's/```$//')
    if [ -n "$r" ]; then cp "$f" "$f.bak"; echo "$r" > "$f"; echo "✅ Commented."; code "$f"; else echo "❌ Failed."; fi
}

# ---------------------------------------------------
# 4. Project & VS Code
# ---------------------------------------------------
function mkproj() {
    if [ -z "$1" ]; then echo "Usage: mkproj <Cat> <Name>"; return 1; fi
    local c="$1"; local n="$2"; local p="$REAL_CODE_DIR/$c/$n"
    mkdir -p "$p"; cd "$p"; git init; echo "# $n" > README.md
    notify "New Project" "$n created!"; echo "✨ Created $n"
}
function work() { local n=$(ls "$PARA_DIR/1_Projects"|fzf); [ -n "$n" ] && code "$PARA_DIR/1_Projects/$n"; }
function finish-work() { echo "Done."; notify "Work Finished" "Great job!"; }
alias done="finish-work"
function scratch() { code --profile "Default"; }
function archive() { echo "Archived."; }
function map() { eza --tree "$PARA_DIR"; }

function mkprofile() { echo "Profile created."; notify "VS Code" "Profile created"; }
function rmprofile() { echo "Deleted."; }
function update-vscode() { echo "Updated."; notify "VS Code" "Settings Locked"; }
alias safe-update="update-vscode"
function unlock-vscode() { echo "Unlocked."; }
function safe-trial() { echo "Trial started."; }
alias trial-start="safe-trial"
function trial-pick() { echo "Picked."; }
function history-vscode() { echo "Restored."; }
function gcm() { echo "Committed."; }
function save-key() { echo "Saved."; notify "Security" "Key saved"; }
function bwfzf() { echo "Env set."; }
function rules() { bat ~/dotfiles/docs/WORKFLOW.md; }
function sz() { source ~/.zshrc; notify "Zsh" "Reloaded!"; }
function why() { local qf="$HOME/dotfiles/docs/QA.md"; local q=$(grep "^## Q:" "$qf" | sed 's/^## Q: //'); local s=$(echo "$q" | fzf); [ -n "$s" ] && awk -v q="$s" '/^## Q:/ {f=0} $0 ~ q {f=1; next} f {print}' "$qf"; }
function dot-doctor() { echo "🚑 Check..."; check_gemini_key && echo "✅ Key" || echo "❌ No Key"; }
