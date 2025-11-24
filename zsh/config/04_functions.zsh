# --- Minimal Functions ---

function dev() {
    echo "🚀 Dev Menu (Safe Mode)"
    echo "1. work (Start Work)"
    echo "2. mkproj (New Project)"
    echo "3. save-dot (Save Dotfiles)"
    echo "4. sz (Reload Shell)"
    
    echo -n "Select number: "
    read num
    case "$num" in
        1) work ;;
        2) echo -n "Name: "; read n; mkproj "Personal" "$n" ;;
        3) cd ~/dotfiles && git add . && git commit -m "save" && git push && cd - ;;
        4) source ~/.zshrc ;;
        *) echo "Canceled." ;;
    esac
}

function work() {
    local dir="$HOME/PARA/1_Projects"
    [ -d "$dir" ] && open "$dir" || echo "Projects folder not found."
}

function mkproj() {
    local name="$2"
    mkdir -p "$HOME/Projects/Personal/$name"
    echo "Created $name"
}
