function p() {
    local n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="🚀 Jump > " --height=40% --layout=reverse)
    [ -n "$n" ] && cd "$HOME/PARA/1_Projects/$n" && { command -v eza >/dev/null && eza --icons || ls; }
}

function briefing() {
    echo ""; gum style --foreground 214 --bold "☀️  MORNING BRIEFING"; echo ""
    gum style --foreground 39 "📉 System:"; uptime | sed 's/^.*up/Up:/' | sed 's/,.*//'
    gum style --foreground 208 "🐙 Git:"; [ -d "$HOME/dotfiles" ] && git -C "$HOME/dotfiles" status -s -b
    echo ""
}

function log() {
    local msg="$*"
    [ -z "$msg" ] && echo "Usage: log 'msg'" && return 1
    local ts=$(date '+%H:%M')
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "- [$ts] $msg" >> "$(git rev-parse --show-toplevel)/docs/DEV_LOG.md"
        echo "✅ Logged to project."
    else
        echo "- [$ts] $msg" >> "$HOME/PARA/0_Inbox/quick_notes.md"
        echo "✅ Logged to Inbox."
    fi
}

function guide() {
    echo ""; gum style --foreground 214 --bold --border double "🧭 COCKPIT HUD"; echo ""
    # srcフォルダ内の全ファイルからエイリアスと関数を抽出
    grep -hE '^alias|^function' "$HOME/dotfiles/zsh/src/"*.zsh | \
    grep -vE '^_|rm=' | sed 's/function //' | sed 's/() {.*//' | sed "s/alias //" | sed "s/=['\"].*//" | \
    xargs | fold -s -w 80
    echo ""
}

function migrate-tools() {
    command -v brew >/dev/null || return 1
    local leaves=$(brew leaves --installed-on-request)
    [ -z "$leaves" ] && echo "✨ Empty." && return 0
    local selected=$(echo "$leaves" | gum choose --no-limit --height 15)
    [ -z "$selected" ] && return 0
    echo "$selected" | while read pkg; do [ -n "$pkg" ] && nix-add "$pkg" "auto"; done
    echo "Remove: brew uninstall $selected"
}

function audit() {
    echo "🩺 Starting Audit..."
    [ -f "flake.nix" ] && nix flake check
    command -v trivy >/dev/null && trivy fs . --severity HIGH,CRITICAL --scanners vuln,config
    echo "✅ Done."
}

function archive() {
    local n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="📦 Archive > ")
    [ -z "$n" ] && return 1
    local src="$HOME/PARA/1_Projects/$n"; local dest="$HOME/PARA/4_Archives/$n"
    if gum confirm "Archive $n?"; then
        mkdir -p "$HOME/PARA/4_Archives"
        mv "$src" "$dest"
        gum style --foreground 214 "🎉 Archived."
    fi
}

function cleanup() {
    echo "🧹 System Detox..."
    if gum confirm "Clean Nix?"; then nh clean all --keep 7d; fi
    if command -v brew >/dev/null; then brew cleanup; fi
    echo "✨ Cleaned."
}

alias b="briefing"
alias l="log"
alias check="audit"
alias arc="archive"
alias mig="migrate-tools"
alias y="y"
alias n="navi"
