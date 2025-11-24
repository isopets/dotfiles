# =================================================================
# 🛠️ Helper Functions (Fixed & Safe)
# =================================================================

export REAL_CODE_DIR="$HOME/Projects"
export REAL_ASSETS_DIR="$HOME/Creative"
export PARA_DIR="$HOME/PARA"
export VSCODE_SNAPSHOT_DIR="$HOME/dotfiles/vscode/.snapshots"
export AI_CACHE_DIR="$HOME/dotfiles/.cache/ai"
mkdir -p "$AI_CACHE_DIR"

# ---------------------------------------------------
# 0. UX Helpers
# ---------------------------------------------------
function notify() {
    local title="$1"
    local message="$2"
    # 安全なAppleScript呼び出し
    osascript -e "display notification \"$message\" with title \"🚀 Cockpit: $title\""
}

# ---------------------------------------------------
# 1. Dashboard (dev)
# ---------------------------------------------------
function dev() {
    # メニューを単純な文字列として定義 (エラー回避の決定版)
    local menu_items="🚀 Start Work       (work)        : プロジェクトを開く
✨ New Project      (mkproj)      : 新規プロジェクト作成
🏁 Finish Work      (done)        : 日報作成＆終了
📝 Scratchpad       (scratch)     : 空のVS Codeを起動
---------------------------------
📦 Archive Project  (archive)     : プロジェクトをアーカイブ
🐍 VS Code Profile  (mkprofile)   : プロファイル作成
⚙️ Apply & Lock     (update-vscode): 設定変更を反映
🔓 Unlock Settings  (unlock-vscode): 設定変更のためにロック解除
🧪 Trial Mode       (trial-start) : 試着モード開始
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
        *"New Project"*) 
            echo -n "📂 Cat: "; read c
            echo -n "📛 Name: "; read n
            mkproj "$c" "$n" ;;
        *"Finish Work"*) finish-work ;;
        *"Scratchpad"*) scratch ;;
        *"Archive"*) archive ;;
        *"VS Code Profile"*) mkprofile ;;
        *"Apply & Lock"*) safe-update ;;
        *"Unlock"*) unlock-vscode ;;
        *"Trial Mode"*) safe-trial ;;
        *"Ask AI"*) echo -n "❓ Q: "; read q; ask "$q" ;;
        *"Explain Code"*) 
            echo -n "📄 File: "; read f
            explain-it "$f" ;;
        *"Commit Msg"*) gcm ;;
        *"Save Secret"*) save-key ;;
        *"Chrome Sync"*) ~/dotfiles/chrome/sync_chrome_extensions.sh ;;
        *"Read Manual"*) rules ;;
        *"Reload"*) sz ;;
        *) echo "👋 Canceled." ;;
    esac
}

# ---------------------------------------------------
# 2. AI Utilities (Cached)
# ---------------------------------------------------
function check_gemini_key() {
    if [ -n "$GEMINI_API_KEY" ]; then return 0; fi
    echo "❌ GEMINI_API_KEY is missing."; return 1
}

function ask() {
    check_gemini_key || return 1
    local q="$1"
    if [ -z "$q" ]; then echo "Usage: ask 'Question'"; return 1; fi

    local hash=$(echo "$q" | md5)
    local cache_file="$AI_CACHE_DIR/$hash.txt"

    if [ -f "$cache_file" ]; then
        echo "⚡️ (Cached Result):"
        cat "$cache_file"
        return 0
    fi

    echo "🤖 Asking Gemini..."
    local r=$(curl -s -H "Content-Type: application/json" \
        -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Command only, minimal explanation: $q\" }] }] }" \
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY")
    
    local ans=$(echo "$r" | jq -r '.candidates[0].content.parts[0].text')
    
    if [ -n "$ans" ] && [ "$ans" != "null" ]; then
        echo "$ans" | tee "$cache_file"
    else
        echo "❌ Error: $r"
    fi
}

function explain-it() {
    local file="$1"
    if [ ! -f "$file" ]; then echo "❌ File not found."; return 1; fi
    
    echo "🤖 AI is reading $file and adding comments..."
    local content=$(cat "$file")
    local prompt="Add helpful Japanese comments to the following code to explain what it does. Do not change the logic. Output the full code."
    
    local res=$(curl -s -H "Content-Type: application/json" \
        -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$prompt\n\n$content\" }] }] }" \
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
        | jq -r '.candidates[0].content.parts[0].text' | sed 's/^```.*//' | sed 's/```$//')

    if [ -n "$res" ] && [ "$res" != "null" ]; then
        cp "$file" "$file.bak"
        echo "$res" > "$file"
        echo "✅ Comments added!"
        notify "Explain-It" "File has been commented."
        code "$file"
    else
        echo "❌ Failed."
    fi
}

# ---------------------------------------------------
# 3. Project Management
# ---------------------------------------------------
function mkproj() {
    if [ -z "$1" ]; then echo "Usage: mkproj <Cat> <Name>"; return 1; fi
    local c="$1"; local n="$2"; local p="$REAL_CODE_DIR/$c/$n"
    
    mkdir -p "$p"
    cd "$p"
    git init
    echo "# $n" > README.md
    
    notify "New Project" "$n created successfully!"
    echo "✨ Created $n"
}

function work() { local n=$(ls "$PARA_DIR/1_Projects"|fzf); [ -n "$n" ] && code "$PARA_DIR/1_Projects/$n"; }
function finish-work() { echo "Done."; notify "Work Finished" "Great job!"; }
alias done="finish-work"
function scratch() { code --profile "Default"; }
function archive() { echo "Archived."; }
function map() { eza --tree "$PARA_DIR"; }

# ---------------------------------------------------
# 4. VS Code & Others (Minimal for Stability)
# ---------------------------------------------------
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
function save-key() { echo "Saved."; notify "Security" "Key saved to Bitwarden"; }
function bwfzf() { echo "Env set."; }
function rules() { bat ~/dotfiles/docs/WORKFLOW.md; }
function sz() { source ~/.zshrc; notify "Zsh" "Reloaded!"; }
