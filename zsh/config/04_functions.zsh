# =================================================================
# 🛠️ Helper Functions (Final Stable Edition)
# =================================================================

export REAL_CODE_DIR="$HOME/Projects"
export REAL_ASSETS_DIR="$HOME/Creative"
export PARA_DIR="$HOME/PARA"
export VSCODE_SNAPSHOT_DIR="$HOME/dotfiles/vscode/.snapshots"
export BW_SESSION_FILE="$HOME/.bw_session"

# --- 0. Bitwarden Session Manager ---
function unlock-bw() {
    if bw status | grep -q "unlocked"; then return 0; fi
    if [ -f "$BW_SESSION_FILE" ]; then export BW_SESSION=$(cat "$BW_SESSION_FILE"); if bw status | grep -q "unlocked"; then return 0; fi; fi
    echo "🔐 Bitwarden is locked."
    local master_pass=""; if command -v security &> /dev/null; then master_pass=$(security find-generic-password -a "$USER" -s "dotfiles-bw-master" -w 2>/dev/null); fi
    if [ -z "$master_pass" ]; then echo "⚠️ Master password not found."; echo -n "🔑 Enter Master Password: "; read -s master_pass; echo ""; if [ -n "$master_pass" ]; then security add-generic-password -a "$USER" -s "dotfiles-bw-master" -w "$master_pass" -U; else echo "❌ Password required."; return 1; fi; fi
    local key=$(echo "$master_pass" | bw unlock --raw); if [ -n "$key" ]; then echo "$key" > "$BW_SESSION_FILE"; export BW_SESSION="$key"; echo "✅ Unlocked."; else echo "❌ Failed."; return 1; fi
}

# --- 1. Dashboard (dev) ---
function dev() {
    local menu_items=$(cat <<END
🚀 Start Work       (work)        : プロジェクトを開く
✨ New Project      (mkproj)      : 新規プロジェクト作成
🏁 Finish Work      (done)        : 日報作成＆終了
📝 Scratchpad       (scratch)     : 空のVS Codeを起動
📦 Archive Project  (archive)     : プロジェクトをアーカイブ
---------------------------------
🗺️  Show Map         (map)         : 環境の全体像を表示
❓ Help / Why       (why)         : 疑問解決Q&A
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
💾 Save Secret      (save-key)    : クリップボードの鍵を保存
🔑 Bitwarden Env    (bwfzf)       : APIキー注入
🌐 Chrome Sync      (chrome-sync) : 拡張機能取り込み
📖 Read Manual      (rules)       : ルール確認
🔄 Reload Shell     (sz)          : 再読み込み
END
    )
    local selected=$(echo "$menu_items" | fzf --prompt="🔥 Dev Menu > " --height=50% --layout=reverse --border)
    case "$selected" in
        *"Start Work"*) work ;;
        *"New Project"*) echo -n "📂 Cat: "; read c; echo -n "📛 Name: "; read n; mkproj "$c" "$n" ;;
        *"Finish Work"*) done ;;
        *"Scratchpad"*) scratch ;;
        *"Archive Project"*) archive ;;
        *"Show Map"*) map ;;
        *"Help / Why"*) why ;;
        *"VS Code Profile"*) mkprofile ;;
        *"Delete Profile"*) rmprofile ;;
        *"Apply & Lock"*) safe-update ;;
        *"Unlock Settings"*) unlock-vscode ;;
        *"Trial Mode"*) safe-trial ;;
        *"Pick & Commit"*) trial-pick ;;
        *"History/Restore"*) history-vscode ;;
        *"Ask AI"*) echo -n "❓ Q: "; read q; ask "$q" ;;
        *"Commit Msg"*) gcm ;;
        *"Save Secret"*) save-key ;;
        *"Bitwarden Env"*) echo -n "📝 Var: "; read k; bwfzf "$k" ;;
        *"Chrome Sync"*) ~/dotfiles/chrome/sync_chrome_extensions.sh ;;
        *"Read Manual"*) rules ;;
        *"Reload Shell"*) sz ;;
        *) echo "👋 Canceled." ;;
    esac
}

# --- 2. Project Management ---
function mkproj() {
    if [ -z "$1" ] || [ -z "$2" ]; then echo "❌ Usage: mkproj <Category> <Name>"; return 1; fi
    local c="$1"; local n="$2"; local code="$REAL_CODE_DIR/$c/$n"; local asset="$REAL_ASSETS_DIR/$c/$n"; local para="$PARA_DIR/1_Projects/$n"
    mkdir -p "$code/.vscode" "$asset"/{Design,Video,Export} "$para"
    ln -s "$asset" "$code/_GoToCreative"; ln -s "$code" "$asset/_GoToCode"
    ln -s "$code" "$para/💻_Code"; ln -s "$asset" "$para/🎨_Assets"
    
    git -C "$code" init
    echo "# $n" > "$code/README.md"
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
        echo "🚀 Launching: $n"
        mkdir -p "$r/docs"; local log="$r/docs/DEV_LOG.md"; [ ! -f "$log" ] && echo "# Dev Log" > "$log"
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
            local p="Git commit message for:\nLog:\n$gl\nDiff:\n$gd"
            local res=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$(echo $p | sed 's/"/\\"/g')\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text')
            echo "- [DONE] $res" >> "$log"
        else echo "- [DONE] (Manual entry)" >> "$log"; fi
    else echo "- [DONE] (Manual entry)" >> "$log"; fi
    code --wait "$log"; git add .; git commit -m "chore: Update log"; git push; echo "🎉 Complete!"
}

function scratch() { local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🐍 Profile > "); [ -n "$p" ] && code --profile "$p"; }
function archive() { local n="$1"; if [ -z "$1" ]; then n=$(ls "$PARA_DIR/1_Projects" | fzf --prompt="📦 Archive > "); [ -z "$n" ] && return 1; fi; mv "$PARA_DIR/1_Projects/$n" "$PARA_DIR/4_Archives/$n"; echo "📦 Archived."; }
function map() { echo "📍 PARA:"; eza --tree --level=2 --icons "$HOME/PARA"; echo "📦 Projects:"; eza --tree --level=2 --icons "$HOME/Projects"; }
function jump() { local c=$(pwd); local t=""; if [[ "$c" == *"/Projects/"* ]]; then t="${c/Projects/Creative}"; else t="${c/Creative/Projects}"; fi; if [ -d "$t" ]; then cd "$t"; echo "🚀 Jumped!"; eza --icons; else echo "⚠️ Target not found."; fi; }

# --- 3. VS Code Management ---
function mkprofile() {
    local vd="$HOME/dotfiles/vscode"; echo -n "📛 Name: "; read n; [ -z "$n" ] && return 1
    local pn="[Lang] $n"; local fn="$(echo "$n"|tr '[:upper:]' '[:lower:]').json"; local fp="$vd/source/$fn"
    if [ ! -f "$fp" ]; then echo "{}" > "$fp"; fi
    if ! grep -q "$pn" "$vd/profile_list.txt"; then echo "$pn:$fn" >> "$vd/profile_list.txt"; fi
    "$vd/update_settings.sh" >/dev/null; "$HOME/dotfiles/setup.sh" >/dev/null
    local sp="$HOME/Library/Application Support/Code/User/profiles/$pn/settings.json"
    [ -f "$sp" ] && chmod +w "$sp"; echo "🚀 Launching..."; code --profile "$pn" .
}

function rmprofile() {
    local list="$HOME/dotfiles/vscode/profile_list.txt"; local sel=$(grep -v "\[Base\] Common" "$list" | fzf --prompt="🗑️ Delete > "); [ -z "$sel" ] && return 1
    local name=$(echo "$sel"|cut -d: -f1); local file=$(echo "$sel"|cut -d: -f2)
    echo "🚨 Delete '$name'? (y/n)"; read c; [ "$c" != "y" ] && return 1
    gsed -i "" "/$name/d" "$list"; rm -f "$HOME/dotfiles/vscode/source/$file"
    "$HOME/dotfiles/vscode/update_settings.sh" >/dev/null; "$HOME/dotfiles/setup.sh" >/dev/null
    rm -rf "$HOME/Library/Application Support/Code/User/profiles/$name"; echo "✨ Deleted."
}

function unlock-vscode() { find "$HOME/Library/Application Support/Code/User/profiles" -name "settings.json" -exec chmod +w {} \;; echo "🔓 Unlocked!"; }
function diff-vscode() { local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🔍 Diff > "); [ -n "$p" ] && bat "$HOME/Library/Application Support/Code/User/profiles/$p/settings.json" -l json; }

# --- 4. Trial & History ---
function take_snapshot() {
    local p="$1"; local r="$2"; local ts=$(date "+%Y-%m-%d_%H-%M-%S")
    local td="$VSCODE_SNAPSHOT_DIR/$p/$ts-$r"; local src="$HOME/Library/Application Support/Code/User/profiles/$p/settings.json"
    if [ -f "$src" ]; then mkdir -p "$td"; cp "$src" "$td/settings.json"; code --list-extensions | sort > "$td/extensions.list"; echo "📸 Saved: $ts"; fi
}
function safe-update() {
    echo "🛑 Locking..."; echo -n "Run? (y/n): "; read c; [ "$c" != "y" ] && return 1
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
    local sd="$VSCODE_SNAPSHOT_DIR/$p"; local ls=$(ls "$sd" | grep "Trial-Start" | sort -r | head -n 1); [ -z "$ls" ] && { echo "❌ No backup."; return 1; }
    local src_ext_list="$sd/$ls/extensions.list"
    local c=$(mktemp)
    cp "$sd/$ls/settings.json" "$HOME/Library/Application Support/Code/User/profiles/$p/settings.json"
    code --list-extensions | sort > "$c"
    local new_exts=$(comm -13 "$src_ext_list" "$c")
    if [ -n "$new_exts" ]; then echo "$new_exts" | while read ext_id; do code --uninstall-extension "$ext_id"; done; fi
    rm "$c"; ~/dotfiles/vscode/update_settings.sh >/dev/null; ~/dotfiles/setup.sh >/dev/null
    echo "✨ Reset."
}

function trial-pick() {
    local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🛍️ Pick > "); [ -z "$p" ] && return 1
    local sd="$VSCODE_SNAPSHOT_DIR/$p"; local ls=$(ls "$sd" | grep "Trial-Start" | sort -r | head -n 1); [ -z "$ls" ] && { echo "❌ Run trial-start first."; return 1; }
    local src_ext_list="$sd/$ls/extensions.list"
    local c=$(mktemp); code --list-extensions|sort > "$c"; local n=$(comm -13 "$src_ext_list" "$c")
    if [ -n "$n" ]; then
        local sel=$(echo "$n" | fzf -m --prompt="Keep > " --preview "echo {}" --bind 'ctrl-a:select-all,ctrl-d:deselect-all'); 
        if [ -n "$sel" ]; then echo "$sel" | while read e; do if ! grep -q "$e" "$HOME/dotfiles/vscode/install_extensions.sh"; then echo "code --install-extension $e" >> "$HOME/dotfiles/vscode/install_extensions.sh"; fi; done; fi
        echo "$n" | while read e; do if ! echo "$sel" | grep -q "$e"; then code --uninstall-extension "$e"; fi; done
    fi
    rm "$c"; diff-vscode; echo "Edit JSON then Enter."; read; safe-update; take_snapshot "$p" "Post-Pick"
}

function history-vscode() {
    local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🕰️ Profile > "); [ -z "$p" ] && return 1
    local snap=$(ls "$VSCODE_SNAPSHOT_DIR/$p" | sort -r | fzf --prompt="Restore > "); [ -z "$snap" ] && return 1
    local src="$VSCODE_SNAPSHOT_DIR/$p/$snap"; cp "$src/settings.json" "$HOME/Library/Application Support/Code/User/profiles/$p/settings.json"
    cat "$src/extensions.list" | while read e; do code --install-extension "$e"; done
    echo "✨ Restored."
}

# --- 5. AI & Utils ---
function ask() {
    check_gemini_key || return 1
    local r=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Command only: $1\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY");
    echo "$r" | jq -r '.candidates[0].content.parts[0].text';
}

function gcm() {
    check_gemini_key || return 1
    local d=$(git diff --cached); [ -z "$d" ] && return 1
    local m=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Git commit message for:\n$d\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text')
    echo "$m"; read -r -p "Commit? (y/n): " c; [ "$c" = "y" ] && git commit -m "$m"
}

function check_gemini_key() {
    if [ -n "$GEMINI_API_KEY" ]; then return 0; fi
    unlock-bw || return 1; echo "🤖 Searching Bitwarden..."; local ap=$(bw get password "Gemini-API-Key" 2>/dev/null);
    if [ -n "$ap" ]; then echo "export GEMINI_API_KEY=\"$ap\"" >> "$HOME/dotfiles/zsh/.zsh_secrets"; source "$HOME/dotfiles/zsh/.zsh_secrets"; return 0; fi
    echo "⚠️ Not found. Please add 'Gemini-API-Key' to Bitwarden."; return 1
}

function save-key() {
    unlock-bw || return 1; local c=$(pbpaste); local n; local k;
    if [[ "$c" == *":::"* ]]; then n=${c%%:::*}; k=${c##*:::}; echo "🚀 Auto-Save: $n";
    else
        k="$c"; echo "📋 Clip: ${k:0:15}..."; echo -n "📛 Name: "; read n
    fi
    if [ -n "$n" ] && [ -n "$k" ]; then echo "{\"type\":1,\"name\":\"$n\",\"login\":{\"username\":\"API_KEY\",\"password\":\"$k\"}}" | bw encode | bw create item > /dev/null; echo "✅ Saved as: $n!"; echo -n "$k" | pbcopy; else echo "❌ Save aborted."; fi
}

function bwenv() { unlock-bw || return 1; local p=$(bw get password "$1"); echo "$2=$p" >> .env; echo "✅ Added."; }
function bwfzf() { unlock-bw || return 1; local i=$(bw list items --search "" | jq -r '.[].name' | fzf --prompt="Select Item > "); [ -n "$i" ] && bwenv "$i" "$1"; }
function ali() { local s=$(alias|fzf|cut -d'='-f1); [ -n "$s" ] && print -z "$s"; }
function myhelp() { cat ~/dotfiles/zsh/config/*.zsh | bat -l bash --style=plain; }
function dot-doctor() {
    echo "🚑 Check..."; local ec=0
    for t in git zoxide eza bat lazygit fzf direnv starship mise bw; do
        if command -v "$t" &> /dev/null; then echo "✅ $t"; else echo "❌ $t missing"; ((ec++)); fi
    done
    if check_gemini_key; then echo "✅ Bitwarden/Key"; else echo "❌ Key/BW Locked"; ((ec++)); fi
    echo "🔥 Issues: $ec"
}
function show-tip() {
    local tips=("💡 z:爆速移動" "💡 work:コックピット" "💡 mkproj:プロジェクト作成" "💡 dev:メニュー" "💡 save-key:キー保存" "💡 rules:マニュアル" "💡 why:Q&A")
    echo "${tips[$RANDOM % ${#tips[@]}]}"
}
