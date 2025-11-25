# =================================================================
# 🐍 VS Code Management Functions
# =================================================================

function mkprofile() {
    echo -n "📛 Profile Name: "
    read n
    if [ -z "$n" ]; then echo "Canceled."; return 1; fi
    
    local pn="[Lang] $n"
    local fn="$(echo "$n" | tr '[:upper:]' '[:lower:]').json"
    local src="$HOME/dotfiles/vscode/source/$fn"
    
    echo "{}" > "$src"
    echo "$pn:$fn" >> "$HOME/dotfiles/vscode/profile_list.txt"
    
    ~/dotfiles/vscode/update_settings.sh
    ~/dotfiles/setup.sh
    
    echo "🚀 Launching $pn..."
    code --profile "$pn" .
}

function rmprofile() {
    local list="$HOME/dotfiles/vscode/profile_list.txt"
    local sel=$(grep -v "Common" "$list" | fzf --prompt="🗑️ Delete > ")
    
    if [ -z "$sel" ]; then echo "Canceled."; return 1; fi
    
    local n=$(echo "$sel" | cut -d: -f1)
    local f=$(echo "$sel" | cut -d: -f2)
    
    # Macのsed (gsedがない場合も考慮)
    sed -i '' "/$n/d" "$list" 2>/dev/null || sed -i "/$n/d" "$list"
    rm -f "$HOME/dotfiles/vscode/source/$f"
    
    rm -rf "$HOME/Library/Application Support/Code/User/profiles/$n"
    echo "✨ Deleted $n"
}

function update-vscode() {
    ~/dotfiles/vscode/update_settings.sh
    echo "✅ Settings Updated & Locked."
}

function unlock-vscode() {
    find "$HOME/Library/Application Support/Code/User/profiles" -name "settings.json" -exec chmod +w {} \;
    echo "🔓 Unlocked settings.json"
}

function diff-vscode() {
    local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🔍 Diff > ")
    if [ -n "$p" ]; then
        bat "$HOME/Library/Application Support/Code/User/profiles/$p/settings.json" -l json
    fi
}

# エイリアス
alias safe-update="update-vscode"
