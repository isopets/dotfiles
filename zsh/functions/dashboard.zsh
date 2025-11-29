function dev() {
    local menu_items="🚀 Start Work       (work)
✨ New Project      (mkproj)
🏁 Finish Work      (done)
📝 Scratchpad       (scratch)
📦 Archive Project  (archive)
---------------------------------
📦 Add Package      (nix-add)
🚀 Update System    (nix-up)
🤖 Ask AI           (ask)
🔄 Reload Shell     (sz)"

    local selected=$(echo "$menu_items" | fzf --prompt="🔥 Cockpit > " --height=60% --layout=reverse --border)
    
    case "$selected" in
        *"Start Work"*) work ;;
        *"New Project"*) echo -n "📂 Cat: "; read c; echo -n "📛 Name: "; read n; mkproj "$c" "$n" ;;
        *"Finish Work"*) finish-work ;;
        *"Scratchpad"*) scratch ;;
        *"Archive"*) archive ;;
        *"Add Package"*) nix-add ;;
        *"Update System"*) nix-up ;;
        *"Ask AI"*) echo -n "❓ Q: "; read q; ask "$q" ;;
        *"Reload"*) sz ;;
        *) echo "👋 Canceled." ;;
    esac
}
