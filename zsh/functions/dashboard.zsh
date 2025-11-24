function dev() {
    local menu_items=$(cat <<MENU
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
MENU
    )
    local selected=$(echo "$menu_items" | fzf --prompt="🔥 Cockpit > " --height=50% --layout=reverse --border)
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
