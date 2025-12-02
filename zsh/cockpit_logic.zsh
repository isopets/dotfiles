# =================================================================
# 🎮 Cockpit Logic (The Neural Link)
# =================================================================

# --- 1. System Context & Safety ---
export DOTFILES="$HOME/dotfiles"
export PATH="$HOME/.nix-profile/bin:$PATH"
setopt +o nomatch
setopt interactivecomments

# Safety First: 事故防止のため rm をブロックし、del (trash-put) を推奨
alias rm="echo '⛔️ Use \"del\" (trash) or \"/bin/rm\"'; false"
alias del="trash-put"

# --- 2. Unified Interface (Smart Edit) ---
function edit() {
    local file="${1:-.}"
    # ファイルサイズが大きい、またはディレクトリなら VS Code
    if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
        gum style --foreground 33 "🚀 VS Code: $file"
        code "$file"
    else
        # 小さな設定ファイルは Neovim (LazyVim) で瞬時に編集
        gum style --foreground 150 "⚡ Neovim: $file"
        nvim "$file"
    fi
}

# --- 3. Productivity Boosters ---

## Jump to Project (Contextual Navigation)
function p() {
    local n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="🚀 Jump to > " --height=40% --layout=reverse)
    if [ -n "$n" ]; then
        cd "$HOME/PARA/1_Projects/$n"
        echo "📂 Moved to: $n"
        if command -v eza >/dev/null; then eza --icons; else ls; fi
    fi
}

## Morning Briefing (Dashboard 2.0)
function briefing() {
    echo ""; gum style --foreground 214 --bold --border double --padding "0 2" --align center "☀️  MORNING BRIEFING"; echo ""
    
    gum style --foreground 39 "📉 System Status:"
    if command -v btm >/dev/null; then
        uptime | sed 's/^.*up/Up:/' | sed 's/,.*//' 
        top -l 1 | grep "CPU usage" | awk '{print "CPU: " $3 " user, " $5 " sys"}'
    else
        uptime
    fi
    echo ""

    gum style --foreground 208 "🐙 Cockpit Git Status:"
    if [ -d "$HOME/dotfiles" ]; then
        git -C "$HOME/dotfiles" status -s -b
    fi
    echo ""

    gum style --foreground 150 "🔥 Active Projects:"
    ls "$HOME/PARA/1_Projects" 2>/dev/null | head -n 5
    echo ""
    
    gum style --italic "Ready to fly? Type 'd' for dashboard."
    echo ""
}

## Quick Capture (Log)
function log() {
    local msg="$*"
    if [ -z "$msg" ]; then echo "Usage: log 'message'"; return 1; fi
    local timestamp=$(date '+%H:%M')
    
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local root=$(git rev-parse --show-toplevel)
        local logfile="$root/docs/DEV_LOG.md"
        [ ! -f "$logfile" ] && mkdir -p "$root/docs" && echo "# Dev Log" > "$logfile"
        echo "- [$timestamp] $msg" >> "$logfile"
        echo "✅ Logged to project: $msg"
    else
        local inbox="$HOME/PARA/0_Inbox/quick_notes.md"
        mkdir -p "$HOME/PARA/0_Inbox"
        echo "- [$(date '+%Y-%m-%d %H:%M')] $msg" >> "$inbox"
        echo "✅ Logged to Inbox: $msg"
    fi
}

# --- 4. Contextual AI & Time Travel ---

## Ask Project (Chat with Codebase)
function ask-project() {
    local q="$1"
    if [ -z "$q" ]; then echo "Usage: ask-project 'question'"; return 1; fi
    
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "❌ Not in a git project."
        return 1
    fi

    echo "🤖 Reading codebase..."
    # テキストファイルのみをコンテキストとして収集
    local context=$(git ls-files | xargs -I {} sh -c 'file -b --mime-type "{}" | grep -q "text" && echo "\n--- {} ---\n" && cat "{}"' 2>/dev/null)
    
    if [ -z "$context" ]; then echo "❌ No text files found."; return 1; fi
    
    local prompt="You are a lead developer. Answer the question based on the following codebase context.\n\nQuestion: $q\n\nCodebase:\n$context"
    echo "🤖 Analyzing project structure..."
    ask "$prompt"
}

## Take Snapshot (Micro-Backup)
function snapshot() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then echo "❌ Not in a git project."; return 1; fi
    local root=$(git rev-parse --show-toplevel)
    local snap_dir="$root/.snapshots"
    local timestamp=$(date "+%Y%m%d_%H%M%S")
    local dest="$snap_dir/snap_$timestamp"

    mkdir -p "$dest"
    echo "📸 Taking snapshot..."
    rsync -av --exclude '.git' --exclude '.snapshots' --exclude 'node_modules' --exclude 'target' --exclude 'dist' "$root/" "$dest/" >/dev/null
    echo "✅ Snapshot saved to: .snapshots/snap_$timestamp"
}

## Restore Snapshot
function restore-snapshot() {
    local root=$(git rev-parse --show-toplevel)
    local snap_dir="$root/.snapshots"
    if [ ! -d "$snap_dir" ]; then echo "❌ No snapshots found."; return 1; fi
    
    local target=$(ls "$snap_dir" | fzf --prompt="🕰️ Select Snapshot to Restore > " --layout=reverse)
    if [ -n "$target" ]; then
        if gum confirm "⚠️  Restore '$target'? Current changes will be overwritten."; then
            echo "🚀 Restoring..."
            rsync -av "$snap_dir/$target/" "$root/" >/dev/null
            echo "✅ Restored."
        fi
    fi
}

# --- 5. Visual & Knowledge Tools ---

## Yazi Wrapper (CWD Support)
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Navi Widget (Ctrl+G) is loaded at the end

# --- 🪟 Window Manager Fixer ---
function fix-yabai() {
    echo "🔧 Fixing Yabai & skhd permissions..."
    
    # 1. サービスの再起動
    echo "🔄 Restarting services..."
    yabai --stop_service
    skhd --stop_service
    
    # 2. パスの特定
    local yabai_path=$(which yabai)
    local skhd_path=$(which skhd)
    
    echo "📍 Yabai path: $yabai_path"
    
    # 3. ガイド表示
    gum style --foreground 214 --border double --padding "1 2" \
        "⚠️  ACTION REQUIRED  ⚠️" \
        "1. Open: System Settings -> Privacy & Security -> Accessibility" \
        "2. Click '+' (Add) button" \
        "3. Press 'Cmd+Shift+G' (Go to folder)" \
        "4. Paste this path: $yabai_path" \
        "5. Do the same for: $skhd_path"
        
    # パスをクリップボードにコピーしてあげる
    echo "$yabai_path" | pbcopy
    echo "📋 Yabai path copied to clipboard!"
    
    # 設定画面を開く
    open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
}

# --- 6. Maintenance & Security ---

## Security Audit
function audit() {
    echo "🩺 Starting Project Audit..."
    [ -f "flake.nix" ] && echo "❄️ Checking Nix Flake..." && nix flake check
    if command -v trivy >/dev/null; then
        echo "🛡️ Scanning for vulnerabilities..."
        trivy fs . --severity HIGH,CRITICAL --scanners vuln,config
    else
        echo "⚠️ Trivy not found."
    fi
    echo "✅ Audit Complete."
}

## Archive Project
function archive() {
    local n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="📦 Archive Project > " --height=40% --layout=reverse)
    if [ -z "$n" ]; then return 1; fi

    local src="$HOME/PARA/1_Projects/$n"
    local dest="$HOME/PARA/4_Archives/$n"
    local real_path=$(readlink "$src/💻_Code")

    if gum confirm "Move '$n' to Archives?"; then
        if [ -n "$GEMINI_API_KEY" ] && [ -d "$real_path" ]; then
            echo "🤖 Generating Project Summary..."
            local log_file="$real_path/docs/DEV_LOG.md"
            [ -f "$log_file" ] && ask "Summarize this project based on:\n$(cat "$log_file")" >> "$log_file"
        fi
        mkdir -p "$HOME/PARA/4_Archives"
        mv "$src" "$dest"
        gum style --foreground 214 "🎉 Archived."
    fi
}

## Migrate Brew to Nix
function migrate-tools() {
    if ! command -v brew >/dev/null; then echo "❌ Homebrew not found."; return 1; fi
    local brew_leaves=$(brew leaves --installed-on-request)
    [ -z "$brew_leaves" ] && echo "✨ No Brew formulas to migrate." && return 0

    echo "📦 Select tools to MIGRATE (Space to select):"
    local selected=$(echo "$brew_leaves" | gum choose --no-limit --height 15)
    [ -z "$selected" ] && echo "👋 Canceled." && return 0

    echo "🚚 Migrating..."
    echo "$selected" | while read pkg; do
        [ -n "$pkg" ] && nix-add "$pkg" "auto"
    done
    
    echo "To remove from Brew: brew uninstall $selected"
}

# --- 7. Auto-Generating Guide ---
function guide() {
    echo ""; gum style --foreground 214 --bold --border double --padding "0 2" "🧭 COCKPIT HUD (Auto-Generated)"; echo ""
    local doc_file="$HOME/dotfiles/zsh/cockpit_logic.zsh"
    local menu_items=$(awk '/^##/ { sub(/^##[ \t]*/, ""); desc = $0; getline; if ($0 ~ /^alias/) { sub(/^alias /, ""); sub(/=.*/, ""); printf "  %-10s : %s\n", $0, desc; } else if ($0 ~ /^function/) { sub(/^function /, ""); sub(/\(\).*/, ""); printf "  %-10s : %s\n", $0, desc; } }' "$doc_file")
    echo "🔥 Available Actions:"; echo "$menu_items"; echo ""
    gum style --foreground 244 -- "=== Shortcuts ==="; echo "  del <file> : Safe Delete"; echo "  Ctrl+R     : History (Atuin)"; echo "  Tab        : Completion (FZF)"
}

# --- 8. Definitions (The Menu) ---

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
## Archive Project
alias arc="archive"
## Migrate Tools
alias mig="migrate-tools"
## Visual File Manager
alias y="y"
## Cheatsheet
alias n="navi"
## Reload
alias sz="exec zsh"

# --- 9. Loader & Init ---
[ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"

if [ -d "$DOTFILES/zsh/functions" ]; then
  for f in "$DOTFILES/zsh/functions/"*.zsh; do [ -r "$f" ] && source "$f"; done
fi

# Navi Widget
if command -v navi >/dev/null; then eval "$(navi widget zsh)"; fi

# Tool Hooks
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
