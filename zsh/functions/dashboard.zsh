function dev() {
    local menu_items="🚀 Start Work       (work)        : プロジェクトを開く
✨ New Project      (mkproj)      : 新規プロジェクト作成
🏁 Finish Work      (done)        : 日報作成＆終了
📝 Scratchpad       (scratch)     : 空のVS Codeを起動
📦 Archive Project  (archive)     : プロジェクトをアーカイブ
---------------------------------
🐍 VS Code Profile  (mkprofile)   : プロファイル作成
🗑️ Delete Profile   (rmprofile)   : プロファイル削除
⚙️ Apply & Lock     (update-vscode): 設定変更を反映
🔓 Unlock Settings  (unlock-vscode): 設定変更のためにロック解除
🧪 Trial Mode       (trial-start) : 試着モード開始
🛍️ Pick & Commit    (trial-pick)  : 試着した拡張機能を選んで採用
🕰️ History (VS Code)(history-vscode): バックアップから復元
---------------------------------
📦 Add Package      (nix-add)     : ツールを追加する
🚀 Update System    (nix-up)      : Nix設定を適用する
🪄 Use Tool         (use)         : ツールを一時的に召喚する
🕰️ History (Nix)    (nix-history) : 過去の設定にタイムスリップ
---------------------------------
🤖 Ask AI           (ask)         : AIに質問
📝 Explain Code     (explain-it)  : ファイルに解説コメントを追記
💬 Commit Msg       (gcm)         : コミットメッセージ生成
💾 Save Secret      (save-key)    : クリップボードの鍵を保存
🔑 Bitwarden Env    (bwfzf)       : APIキー注入
🌐 Chrome Sync      (chrome-sync) : 拡張機能取り込み
📖 Read Manual      (rules)       : ルール確認
🔄 Reload Shell     (sz)          : 再読み込み"

    local selected=$(echo "$menu_items" | fzf --prompt="🔥 Cockpit > " --height=60% --layout=reverse --border)
    
    case "$selected" in
        *"Start Work"*) work ;;
        *"New Project"*) echo -n "📂 Cat: "; read c; echo -n "📛 Name: "; read n; mkproj "$c" "$n" ;;
        *"Finish Work"*) finish-work ;;
        *"Scratchpad"*) scratch ;;
        *"Archive"*) archive ;;
        *"VS Code Profile"*) mkprofile ;;
        *"Delete Profile"*) rmprofile ;;
        *"Apply"*) safe-update ;;
        *"Unlock"*) unlock-vscode ;;
        *"Trial Mode"*) safe-trial ;;
        *"Pick"*) trial-pick ;;
        *"History (VS Code)"*) history-vscode ;;
        *"Add Package"*) nix-add ;;
        *"Update System"*) nix-up ;;
        *"Use Tool"*) echo -n "🧙 Pkg: "; read p; use "$p" ;;
        *"History (Nix)"*) nix-history ;;
        *"Ask AI"*) echo -n "❓ Q: "; read q; ask "$q" ;;
        *"Explain Code"*) echo -n "📄 File: "; read f; explain-it "$f" ;;
        *"Commit Msg"*) gcm ;;
        *"Save Secret"*) save-key ;;
        *"Bitwarden Env"*) echo -n "📝 Var: "; read k; bwfzf "$k" ;;
        *"Chrome Sync"*) ~/dotfiles/chrome/sync_chrome_extensions.sh ;;
        *"Manual"*) rules ;;
        *"Reload"*) sz ;;
        *) echo "👋 Canceled." ;;
    esac
}