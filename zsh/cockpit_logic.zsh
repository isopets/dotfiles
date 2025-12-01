# =================================================================
# 🎮 Cockpit Logic (Live Editable & Auto-Docs)
# =================================================================

# --- 1. System Context ---
export DOTFILES="$HOME/dotfiles"
export PATH="$HOME/.nix-profile/bin:$PATH"
setopt +o nomatch
setopt interactivecomments

# --- 2. Safety First ---
alias rm="echo '⛔️ Use \"del\" (trash) or \"/bin/rm\"'; false"
alias del="trash-put"

# --- 3. Unified Interface ---
function edit() {
    local file="${1:-.}"
    if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
        gum style --foreground 33 "🚀 VS Code: $file"
        code "$file"
    else
        gum style --foreground 150 "⚡ Neovim: $file"
        nvim "$file"
    fi
}

# --- 4. Productivity Boosters ---

## Jump to Project (Contextual Navigation)
function p() {
    local n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="🚀 Jump to > " --height=40% --layout=reverse)
    if [ -n "$n" ]; then
        cd "$HOME/PARA/1_Projects/$n"
        echo "📂 Moved to: $n"
        # 中身をチラ見せ
        if command -v eza >/dev/null; then eza --icons; else ls; fi
    fi
}

## Morning Briefing (Dashboard 2.0)
function briefing() {
    echo ""
    gum style --foreground 214 --bold --border double --padding "0 2" --align center "☀️  MORNING BRIEFING"
    echo ""
    
    # 1. System Health
    gum style --foreground 39 "📉 System Status:"
    if command -v btm >/dev/null; then
        # bottom の簡易表示 (実際は対話型なので、ここではuptimeなどを表示)
        uptime | sed 's/^.*up/Up:/' | sed 's/,.*//' 
        top -l 1 | grep "CPU usage" | awk '{print "CPU: " $3 " user, " $5 " sys"}'
    else
        uptime
    fi
    echo ""

    # 2. Cockpit Status
    gum style --foreground 208 "🐙 Cockpit Git Status:"
    if [ -d "$HOME/dotfiles" ]; then
        git -C "$HOME/dotfiles" status -s
        local branch=$(git -C "$HOME/dotfiles" branch --show-current)
        echo "Branch: $branch"
    fi
    echo ""

    # 3. Active Projects
    gum style --foreground 150 "🔥 Active Projects:"
    ls "$HOME/PARA/1_Projects" 2>/dev/null | head -n 5
    echo ""
    
    gum style --italic "Ready to fly? Type 'd' for dashboard."
    echo ""
}

# --- 🧠 Contextual AI (RAG-lite) ---

function ask-project() {
    local q="$1"
    if [ -z "$q" ]; then echo "Usage: ask-project 'question'"; return 1; fi
    
    # プロジェクト内チェック
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "❌ Not in a git project."
        return 1
    fi

    echo "🤖 Reading codebase..."
    
    # git管理下のテキストファイルのみを収集 (バイナリやlockファイルを除外)
    # 巨大すぎる場合は制限をかけるロジックが必要だが、Gemini 2.0ならある程度いける
    local context=$(git ls-files | xargs -I {} sh -c 'file -b --mime-type "{}" | grep -q "text" && echo "\n--- {} ---\n" && cat "{}"' 2>/dev/null)
    
    if [ -z "$context" ]; then
        echo "❌ No text files found."
        return 1
    fi
    
    local prompt="You are a lead developer. Answer the question based on the following codebase context.\n\nQuestion: $q\n\nCodebase:\n$context"
    
    # ask関数を経由してGeminiに投げる
    # (トークン量が多いため、少し時間がかかる場合があります)
    echo "🤖 Analyzing project structure (sending context)..."
    ask "$prompt"
}

# --- 📸 Micro-Snapshots (Time Travel) ---

function snapshot() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "❌ Not in a git project."
        return 1
    fi

    local root=$(git rev-parse --show-toplevel)
    local snap_dir="$root/.snapshots"
    local timestamp=$(date "+%Y%m%d_%H%M%S")
    local dest="$snap_dir/snap_$timestamp"

    mkdir -p "$dest"
    
    echo "📸 Taking snapshot..."
    
    # rsyncで高速バックアップ (.git, .snapshots, node_modules 除外)
    rsync -av --exclude '.git' --exclude '.snapshots' --exclude 'node_modules' --exclude 'target' --exclude 'dist' "$root/" "$dest/" >/dev/null
    
    echo "✅ Snapshot saved to: .snapshots/snap_$timestamp"
}

function restore-snapshot() {
    local root=$(git rev-parse --show-toplevel)
    local snap_dir="$root/.snapshots"
    
    if [ ! -d "$snap_dir" ]; then echo "❌ No snapshots found."; return 1; fi
    
    # スナップショットを選択
    local target=$(ls "$snap_dir" | fzf --prompt="🕰️ Select Snapshot to Restore > " --layout=reverse)
    
    if [ -n "$target" ]; then
        if gum confirm "⚠️  Restore '$target'? Current changes will be overwritten."; then
            echo "🚀 Restoring..."
            rsync -av "$snap_dir/$target/" "$root/" >/dev/null
            echo "✅ Restored."
        fi
    fi
}

# --- 5. Auto-Generating Guide ---
function guide() {
    echo ""
    gum style --foreground 214 --bold --border double --padding "0 2" "🧭 COCKPIT HUD (Auto-Generated)"
    echo ""

    local doc_file="$HOME/dotfiles/zsh/cockpit_logic.zsh"
    local menu_items=$(awk '
        /^##/ { 
            sub(/^##[ \t]*/, ""); desc = $0; getline; 
            if ($0 ~ /^alias/) { sub(/^alias /, ""); sub(/=.*/, ""); printf "  %-10s : %s\n", $0, desc; }
            else if ($0 ~ /^function/) { sub(/^function /, ""); sub(/\(\).*/, ""); printf "  %-10s : %s\n", $0, desc; }
        }
    ' "$doc_file")

    echo "🔥 Available Actions:"
    echo "$menu_items"
    echo ""
    gum style --foreground 244 -- "=== Shortcuts ==="
    echo "  del <file> : Safe Delete"
    echo "  Ctrl+R     : History (Atuin)"
    echo "  Tab        : Completion (FZF)"
}

# --- ⚡️ Quick Capture ---
function log() {
    local msg="$*"
    if [ -z "$msg" ]; then echo "Usage: log 'message'"; return 1; fi

    local timestamp=$(date '+%H:%M')
    
    # プロジェクト内にいる場合
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local root=$(git rev-parse --show-toplevel)
        local logfile="$root/docs/DEV_LOG.md"
        
        if [ ! -f "$logfile" ]; then
            mkdir -p "$root/docs"
            echo "# Dev Log" > "$logfile"
        fi
        
        # 追記
        echo "- [$timestamp] $msg" >> "$logfile"
        echo "✅ Logged to project: $msg"
        
    else
        # グローバルの場合 (Inboxへ)
        local inbox="$HOME/PARA/0_Inbox/quick_notes.md"
        echo "- [$(date '+%Y-%m-%d %H:%M')] $msg" >> "$inbox"
        echo "✅ Logged to Inbox: $msg"
    fi
}

# --- 6. Definitions (Guide Menu) ---

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

## Smart Editor
alias e="edit"

## Ask AI
alias a="ask"

## Git Cockpit
alias g="lazygit"

## Workspace
alias zj="zellij"

## Security Check
alias check="audit"

## Archive Project
alias arc="archive"

## Reload
alias sz="exec zsh"

# --- 7. Loader ---
[ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"

if [ -d "$DOTFILES/zsh/functions" ]; then
  for f in "$DOTFILES/zsh/functions/"*.zsh; do
    [ -r "$f" ] && source "$f"
  done
fi

# --- 8. Init ---
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
