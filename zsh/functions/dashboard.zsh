# =================================================================
# 🧭 Dashboard Functions (dev) - INTEGRATED
# =================================================================

function dev() {
    local selected
    
    # 1. コンテキスト判定
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local mode="PROJECT"
        # 🟠 プロジェクトモード
        local header_text="🔥 ACTIVE PROJECT"
        local bg_color="214" 
        local fg_color="0"   
        
        local options=(
            "🚀 Start Work       (VS Code / Assets)"
            "🕹️  Git Control      (Lazygit TUI)"        # <--- NEW!
            "🏁 Finish Work      (Log & Commit)"
            "📝 Scratchpad       (Quick Note)"
            "💬 Commit Msg       (AI Auto-Gen)"
            "🧠 Explain Code     (AI Analysis)"
        )
    else
        local mode="GLOBAL"
        # 🔵 グローバルモード
        local header_text="🌍 COCKPIT CONTROL"
        local bg_color="39"
        local fg_color="0"
        
        local options=(
            "✨ New Project      (Create)"
            "📦 Archive Project  (Move to Storage)"
            "---------------------------------------"
            "📦 Add Package      (Nix)"
            "🚀 Update System    (Nix-Up)"
            "🤖 Ask AI           (Gemini)"
            "📖 Manual           (Docs)"
            "🔄 Reload           (Shell)"
        )
    fi

    echo "" 

    # 2. ヘッダー表示
    gum style \
        --padding "0 2" \
        --margin "0 1" \
        --background "$bg_color" \
        --foreground "$fg_color" \
        --bold \
        "$header_text"

    echo "" 

    # 3. メニュー選択
    selected=$(printf "%s\n" "${options[@]}" | gum choose \
        --cursor="👉 " \
        --cursor.foreground="214" \
        --selected.foreground="255" \
        --height 12)

    # 4. フッター
    echo ""
    gum style --foreground 240 --italic "💡 Tip: Select via Mouse or Keys"

    # 5. 処理分岐
    case "$selected" in
        *"Start Work"*) work ;;
        *"Git Control"*) lazygit ;; # <--- NEW!
        *"New Project"*) mkproj ;; 
        *"Finish Work"*) finish-work ;;
        *"Scratchpad"*) scratch ;;
        *"Archive"*) archive ;;
        *"Add Package"*) nix-add ;;
        *"Update System"*) nix-up ;;
        *"Ask AI"*) echo -n "❓ Q: "; read q; ask "$q" ;;
        *"Explain Code"*) echo -n "📄 File: "; read f; explain-it "$f" ;;
        *"Commit Msg"*) gcm ;;
        *"Manual"*) rules ;;
        *"Reload"*) sz ;;
        *) echo "👋 Done." ;;
    esac
}
