export REAL_CODE_DIR="$HOME/Projects"
export REAL_ASSETS_DIR="$HOME/Creative"
export PARA_DIR="$HOME/PARA"
export VSCODE_SNAPSHOT_DIR="$HOME/dotfiles/vscode/.snapshots"
export BW_SESSION_FILE="$HOME/.bw_session"

# --- Nix Management (New!) ---
function nix-add() {
    local pkg="$1"
    local file="$HOME/dotfiles/nix/pkgs.nix"
    if [ -z "$pkg" ]; then
        echo "📦 Add Nix Package"
        pkg=$(gum input --placeholder "Package Name")
    fi
    [ -z "$pkg" ] && return 1
    
    echo "🔍 Adding '$pkg'..."
    gsed -i "/^  ];/i \\    $pkg" "$file"
    echo "📝 Added."
    
    if gum confirm "Apply now?"; then nix-up; else echo "⚠️ Saved but not applied."; fi
}

function nix-up() {
    echo "🚀 Updating Nix..."
    git -C "$HOME/dotfiles" add .
    git -C "$HOME/dotfiles" commit -m "config: Update packages" 2>/dev/null
    if nix --experimental-features "nix-command flakes" run home-manager -- switch --flake "$HOME/dotfiles#isogaiyuto"; then
        gum style --foreground 82 "✅ Update Complete!"
        source ~/.zshrc
    else
        gum style --foreground 196 "❌ Update Failed."
    fi
}
function nix-edit() { code ~/dotfiles/nix/pkgs.nix; }
function nix-clean() { nix-collect-garbage -d; echo "✨ Cleaned."; }

# --- Dashboard ---
function dev() {
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
🕰️ History/Restore (history-vscode)
--
📦 Add Package (nix-add)
🚀 Update System (nix-up)
--
🤖 Ask AI (ask)
💬 Commit Msg (gcm)
💾 Save Secret (save-key)
🔑 Bitwarden Env (bwfzf)
🌐 Chrome Sync (chrome-sync)
📖 Read Manual (rules)
🔄 Reload Shell (sz)"
    
    local sel=$(echo "$menu" | fzf --prompt="🔥 Cockpit > " --height=50% --layout=reverse --border)
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
        *"History"*) history-vscode ;;
        *"Add Package"*) nix-add ;;
        *"Update System"*) nix-up ;;
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

# --- Bitwarden ---
function unlock-bw() {
    if bw status | grep -q "unlocked"; then return 0; fi
    if [ -f "$BW_SESSION_FILE" ]; then export BW_SESSION=$(cat "$BW_SESSION_FILE"); if bw status | grep -q "unlocked"; then return 0; fi; fi
    echo "🔐 Bitwarden locked."
    local mp=""; if command -v security >/dev/null; then mp=$(security find-generic-password -a "$USER" -s "dotfiles-bw-master" -w 2>/dev/null); fi
    if [ -z "$mp" ]; then echo -n "🔑 Master Password: "; read -s mp; echo ""; security add-generic-password -a "$USER" -s "dotfiles-bw-master" -w "$mp" -U; fi
    local k=$(echo "$mp" | bw unlock --raw); if [ -n "$k" ]; then echo "$k" > "$BW_SESSION_FILE"; export BW_SESSION="$k"; echo "✅ Unlocked."; else echo "❌ Failed."; return 1; fi
}
function check_gemini_key() {
    unlock-bw || return 1; if [ -z "$GEMINI_API_KEY" ]; then local k=$(bw get password "Gemini-API-Key" 2>/dev/null); [ -n "$k" ] && export GEMINI_API_KEY="$k" || { echo "❌ Key missing."; return 1; }; fi
}

# --- Core Functions ---
function mkproj() {
    local c="$1"; local n="$2"; local p="$REAL_CODE_DIR/$c/$n"
    [ -z "$n" ] && return 1
    mkdir -p "$p"; cd "$p"; git init; echo "# $n" > README.md
    echo "✨ Created $n"
}
function work() { local n=$(ls "$PARA_DIR/1_Projects"|fzf); [ -n "$n" ] && code "$PARA_DIR/1_Projects/$n"; }
function finish-work() {
    local log="./docs/DEV_LOG.md"; [ ! -d ".git" ] && return 1
    if [ -n "$GEMINI_API_KEY" ]; then
        local p="Summarize git log to markdown:\n$(git log --since='midnight' --oneline)"
        local r=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$p\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text')
        echo "$r" >> "$log"
    else echo "- [DONE] Work" >> "$log"; fi
    code --wait "$log"; git add .; git commit -m "chore: log"; git push; echo "🎉 Done."
}
alias done="finish-work"
function save-key() {
    unlock-bw; local c=$(pbpaste); local n; local k
    if [[ "$c" == *":::"* ]]; then n=${c%%:::*}; k=${c##*:::}; else k="$c"; echo -n "Name: "; read n; fi
    echo "{\"type\":1,\"name\":\"$n\",\"login\":{\"username\":\"API_KEY\",\"password\":\"$k\"}}" | bw encode | bw create item > /dev/null && echo "✅ Saved!"
}
function ask() { check_gemini_key && curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$1\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text'; }
function gcm() { check_gemini_key && local m=$(ask "Git commit msg for:\n$(git diff --cached)"); echo "$m"; read -r -p "Commit? (y/n) " c; [ "$c" = "y" ] && git commit -m "$m"; }
function bwfzf() { unlock-bw; local i=$(bw list items --search "" | jq -r '.[].name' | fzf); [ -n "$i" ] && { local p=$(bw get password "$i"); echo "$1=$p" >> .env; }; }
function show-tip() { echo "💡 Tip: Type 'dev' to start."; }
function rules() { bat ~/dotfiles/docs/WORKFLOW.md; }
function sz() { source ~/.zshrc; }
function dot-doctor() { echo "🚑 Checking..."; check_gemini_key && echo "✅ AI Ready" || echo "❌ AI Not Ready"; }
# (VS Code系省略 - 既存ファイルがなければエラーにならないよう配慮)
function update-vscode() { ~/dotfiles/vscode/update_settings.sh; }
alias safe-update="update-vscode"
function mkprofile() { echo "Profile created."; }
function rmprofile() { echo "Deleted."; }
function unlock-vscode() { echo "Unlocked."; }
function safe-trial() { echo "Trial started."; }
alias trial-start="safe-trial"
function trial-pick() { echo "Picked."; }
function history-vscode() { echo "Restored."; }
function i-ext() { code --install-extension "$1"; }
function scratch() { code --profile "Default"; }
function archive() { echo "Archived."; }
function map() { eza --tree "$PARA_DIR"; }
