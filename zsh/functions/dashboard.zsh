function dev() {
    # メニュー定義 (フルバージョン)
    local menu="🚀 Start Work (work)
✨ New Project (mkproj)
🏁 Finish Work (done)
📝 Scratchpad (scratch)
📦 Archive Project (archive)
--
🐍 VS Code Profile (mkprofile)
🗑️ Delete Profile (rmprofile)
⚙️ Apply & Lock (update-vscode)
🔓 Unlock Settings (unlock-vscode)
🧪 Trial Mode (trial-start)
🛍️ Pick & Commit (trial-pick)
🕰️ History (VS Code) (history-vscode)
--
📦 Add Package (nix-add)
🚀 Update System (nix-up)
🪄 Use Tool (use)
🕰️ History (Nix System) (nix-history)
--
🤖 Ask AI (ask)
💬 Commit Msg (gcm)
💾 Save Secret (save-key)
🔑 Bitwarden Env (bwfzf)
🌐 Chrome Sync (chrome-sync)
📖 Read Manual (rules)
🔄 Reload Shell (sz)"
    
    # fzfで選択
    local sel=$(echo "$menu" | fzf --prompt="🔥 Cockpit > " --height=60% --layout=reverse --border)
    
    # 実行
    case "$sel" in
        *"Start Work"*) work ;;
        *"New Project"*) echo -n "Name: "; read n; mkproj "Personal" "$n" ;;
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
        *"Use Tool"*) echo -n "Pkg: "; read p; use "$p" ;;
        *"History (Nix System)"*) nix-history ;;
        *"Ask AI"*) echo -n "Q: "; read q; ask "$q" ;;
        *"Commit Msg"*) gcm ;;
        *"Save Secret"*) save-key ;;
        *"Bitwarden Env"*) bwfzf ;;
        *"Chrome Sync"*) ~/dotfiles/chrome/sync_chrome_extensions.sh ;;
        *"Manual"*) rules ;;
        *"Reload"*) sz ;;
        *) echo "Canceled." ;;
    esac
}
