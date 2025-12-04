# =================================================================
# 🎮 Cockpit Logic (v2.0)
# =================================================================

# --- 1. Context & Safety ---
export DOTFILES="$HOME/dotfiles"
export PATH="$HOME/.nix-profile/bin:$PATH"
setopt +o nomatch
setopt interactivecomments
alias rm="echo '⛔️ Use \"del\"'; false"
alias del="trash-put"

# --- 2. Omni-Command (c) ---
function c() {
    local subcmd="$1"; shift
    case "$subcmd" in
        "")         dev ;;
        "w"|"work") work "$@" ;;
        "n"|"new")  mkproj "$@" ;;
        "f"|"fin")  finish-work ;;
        "go"|"p")   p ;;
        "e"|"edit") edit "$@" ;;
        "ai"|"ask") ask "$@" ;;
        "ap")       ask-project "$@" ;;
        "l"|"log")  log "$@" ;;
        "g"|"git")  lazygit ;;
        "z"|"zj")   zellij ;;
        "up")       nix-up ;;
        "check")    audit ;;
        "clean")    cleanup ;;
        "fix")      sz ;;
        "b")        briefing ;;
        *) echo "❌ Unknown: c $subcmd" ;;
    esac
}

# --- 3. Core Logic ---
function edit() {
    local file="${1:-.}"
    if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
        gum style --foreground 33 "🚀 VS Code: $file"; code "$file"
    else
        gum style --foreground 150 "⚡ Neovim: $file"; nvim "$file"
    fi
}

function p() {
    local n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="🚀 Jump > " --height=40% --layout=reverse)
    [ -n "$n" ] && cd "$HOME/PARA/1_Projects/$n" && { command -v eza >/dev/null && eza --icons || ls; }
}

function briefing() {
    echo ""; gum style --foreground 214 --bold --border double --padding "0 2" --align center "☀️  MORNING BRIEFING"; echo ""
    gum style --foreground 39 "📉 System:"; uptime | sed 's/^.*up/Up:/' | sed 's/,.*//'; echo ""
    gum style --foreground 208 "🐙 Git:"; [ -d "$HOME/dotfiles" ] && git -C "$HOME/dotfiles" status -s -b; echo ""
    gum style --foreground 150 "🔥 Projects:"; ls "$HOME/PARA/1_Projects" 2>/dev/null | head -n 5; echo ""
}

function log() {
    local msg="$*"
    [ -z "$msg" ] && echo "Usage: log 'msg'" && return 1
    local timestamp=$(date '+%H:%M')
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local root=$(git rev-parse --show-toplevel)
        echo "- [$timestamp] $msg" >> "$root/docs/DEV_LOG.md"
        echo "✅ Logged to project."
    else
        echo "- [$(date '+%Y-%m-%d %H:%M')] $msg" >> "$HOME/PARA/0_Inbox/quick_notes.md"
        echo "✅ Logged to Inbox."
    fi
}

function ask-project() {
    local q="$1"; [ -z "$q" ] && echo "Usage: ask-project 'q'" && return 1
    ! git rev-parse --is-inside-work-tree >/dev/null 2>&1 && echo "❌ Not in git repo." && return 1
    echo "🤖 Reading codebase..."
    local context=$(git ls-files | xargs -I {} sh -c 'file -b --mime-type "{}" | grep -q "text" && echo "\n--- {} ---\n" && cat "{}"' 2>/dev/null)
    [ -z "$context" ] && echo "❌ No text files." && return 1
    echo "🤖 Analyzing..."
    ask "Answer based on codebase:\n\nQuestion: $q\n\nCode:\n$context"
}

function snapshot() {
    local root=$(git rev-parse --show-toplevel 2>/dev/null); [ -z "$root" ] && echo "❌ No git." && return 1
    local dest="$root/.snapshots/snap_$(date "+%Y%m%d_%H%M%S")"
    mkdir -p "$dest"
    rsync -av --exclude '.git' --exclude '.snapshots' --exclude 'node_modules' "$root/" "$dest/" >/dev/null
    echo "📸 Snapshot saved."
}

function restore-snapshot() {
    local root=$(git rev-parse --show-toplevel 2>/dev/null); [ -z "$root" ] && echo "❌ No git." && return 1
    local snap_dir="$root/.snapshots"
    [ ! -d "$snap_dir" ] && echo "❌ No snapshots." && return 1
    local target=$(ls "$snap_dir" | fzf --prompt="🕰️ Restore > " --layout=reverse)
    [ -n "$target" ] && gum confirm "Overwrite?" && rsync -av "$snap_dir/$target/" "$root/" >/dev/null && echo "✅ Restored."
}

function migrate-tools() {
    command -v brew >/dev/null || return 1
    local leaves=$(brew leaves --installed-on-request); [ -z "$leaves" ] && echo "✨ Empty." && return 0
    local selected=$(echo "$leaves" | gum choose --no-limit --height 15)
    [ -z "$selected" ] && return 0
    echo "$selected" | while read pkg; do [ -n "$pkg" ] && nix-add "$pkg" "auto"; done
    echo "Remove: brew uninstall $selected"
}

function guide() {
    echo ""; gum style --foreground 214 --bold --border double --padding "0 2" "🧭 COCKPIT HUD"; echo ""
    awk '/^##/ { sub(/^##[ \t]*/, ""); desc = $0; getline; if ($0 ~ /^alias/) { sub(/^alias /, ""); sub(/=.*/, ""); printf "  %-10s : %s\n", $0, desc; } else if ($0 ~ /^function/) { sub(/^function /, ""); sub(/\(\).*/, ""); printf "  %-10s : %s\n", $0, desc; } }' "$HOME/dotfiles/zsh/cockpit_logic.zsh"
    echo ""; gum style --foreground 244 -- "=== Shortcuts ==="; echo "  del <file> : Safe Delete"; echo "  Ctrl+R     : History"; echo "  Tab        : Completion"
}

# --- 4. Menu Definitions ---
## Morning Briefing
alias b="briefing"
## Dashboard
alias d="dev"
## Jump to Project
alias p="p"
## Work Mode
alias w="work"
## New Project
alias m="mkproj"
## Finish Work
alias f="finish-work"
## Quick Capture
alias l="log"
## Smart Editor
alias e="edit"
## Ask AI
alias a="ask"
## Ask Project
alias ap="ask-project"
## Snapshot
alias snap="snapshot"
## Restore Snap
alias snap-restore="restore-snapshot"
## Git Cockpit
alias g="lazygit"
## Workspace
alias zj="zellij"
## Security Check
alias check="audit"
## Archive
alias arc="archive"
## Migrate
alias mig="migrate-tools"
## Visual FM
alias y="y"
## Cheat
alias n="navi"
## Reload
alias sz="exec zsh"

# --- 5. Loader ---
[ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"
if [ -d "$DOTFILES/zsh/functions" ]; then for f in "$DOTFILES/zsh/functions/"*.zsh; do [ -r "$f" ] && source "$f"; done; fi

# --- 6. Init ---
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
[ -f "$(which navi)" ] && eval "$(navi widget zsh)"
