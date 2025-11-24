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
    gsed -i "/$name/d" "$list"; rm -f "$HOME/dotfiles/vscode/source/$file"
    "$HOME/dotfiles/vscode/update_settings.sh" >/dev/null; "$HOME/dotfiles/setup.sh" >/dev/null
    rm -rf "$HOME/Library/Application Support/Code/User/profiles/$name"; echo "✨ Deleted."
}
function unlock-vscode() { find "$HOME/Library/Application Support/Code/User/profiles" -name "settings.json" -exec chmod +w {} \;; echo "🔓 Unlocked!"; }
function diff-vscode() { local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🔍 Diff > "); [ -n "$p" ] && bat "$HOME/Library/Application Support/Code/User/profiles/$p/settings.json" -l json; }
function take_snapshot() {
    local p="$1"; local r="$2"; local ts=$(date "+%Y-%m-%d_%H-%M-%S"); local td="$VSCODE_SNAPSHOT_DIR/$p/$ts-$r"; local src="$HOME/Library/Application Support/Code/User/profiles/$p/settings.json"
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
    cp "$sd/$ls/settings.json" "$HOME/Library/Application Support/Code/User/profiles/$p/settings.json"
    local c=$(mktemp); code --list-extensions|sort > "$c"; local n=$(comm -13 "$sd/$ls/extensions.list" "$c")
    [ -n "$n" ] && echo "$n" | while read e; do code --uninstall-extension "$e"; done
    rm "$c"; ~/dotfiles/vscode/update_settings.sh >/dev/null; ~/dotfiles/setup.sh >/dev/null; echo "✨ Reset."
}
function trial-pick() {
    local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🛍️ Pick > "); [ -z "$p" ] && return 1
    local bd="$HOME/dotfiles/vscode/.backup/$p"; [ ! -f "$bd/extensions.list.bak" ] && { echo "❌ No backup."; return 1; }
    local c=$(mktemp); code --list-extensions|sort > "$c"; local n=$(comm -13 "$bd/extensions.list.bak" "$c")
    if [ -n "$n" ]; then
        local sel=$(echo "$n" | fzf -m --prompt="Keep > " --preview "echo {}" --bind 'ctrl-a:select-all,ctrl-d:deselect-all'); 
        if [ -n "$sel" ]; then echo "$sel" >> "$HOME/dotfiles/vscode/install_extensions.sh"; fi
        echo "$n" | while read e; do if ! echo "$sel" | grep -q "$e"; then code --uninstall-extension "$e"; fi; done
    fi
    rm "$c"; diff-vscode "$p"; echo "Edit JSON then Enter."; read; safe-update; take_snapshot "$p" "Post-Pick"
}
function history-vscode() {
    local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🕰️ Profile > "); [ -z "$p" ] && return 1
    local snap=$(ls "$VSCODE_SNAPSHOT_DIR/$p" | sort -r | fzf --prompt="Restore > "); [ -z "$snap" ] && return 1
    local src="$VSCODE_SNAPSHOT_DIR/$p/$snap"; cp "$src/settings.json" "$HOME/Library/Application Support/Code/User/profiles/$p/settings.json"
    cat "$src/extensions.list" | while read e; do code --install-extension "$e"; done
    echo "✨ Restored."
}
function i-ext() {
    local id="$1"; local list="$HOME/dotfiles/vscode/install_extensions.sh"
    if [ -z "$id" ]; then
        local clip=$(pbpaste | xargs); if [[ "$clip" =~ ^[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+$ ]]; then echo "📋 ID: $clip"; echo -n "Install? (y/n): "; read c; [ "$c" = "y" ] && id="$clip"; fi
    fi
    [ -z "$id" ] && { echo -n "📝 ID: "; read id; }
    local p=$(grep -v "^#" "$HOME/dotfiles/vscode/profile_list.txt" | cut -d: -f1 | fzf --prompt="🎯 Profile > "); [ -z "$p" ] && return 1
    echo "🔎 Analyzing..."
    if [ -n "$GEMINI_API_KEY" ]; then
        local info=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Describe VS Code extension '$id' in 1 line and rate safety.\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text')
        echo "🤖 AI: $info"
    fi
    echo -n "Install? (y/n): "; read c; [ "$c" != "y" ] && return 1
    if [[ "$p" == "[Base] Common" ]]; then code --install-extension "$id"; else code --profile "$p" --install-extension "$id"; fi
    [ $? -eq 0 ] && echo "code --install-extension $id" >> "$list" && echo "✅ Done." || echo "❌ Failed."
}
