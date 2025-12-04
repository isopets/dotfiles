function mkproj() {
    local c="$1"; local n="$2"
    if [ -z "$c" ]; then
        c=$(ls -F "$HOME/Projects" 2>/dev/null | grep "/" | tr -d "/" | fzf --prompt="📂 Category > ")
        [ -z "$c" ] && return 1
    fi
    [ -z "$n" ] && echo -n "📛 Name: " && read n
    local p="$HOME/Projects/$c/$n"; local para="$HOME/PARA/1_Projects/$n"
    [ -d "$p" ] && echo "❌ Exists" && return 1
    
    mkdir -p "$p/.vscode" "$para"
    ln -s "$p" "$para/💻_Code"
    git -C "$p" init
    echo "# $n" > "$p/README.md"
    
    cat << 'JUST' > "$p/Justfile"
set shell := ["zsh", "-c"]
default:
    @just --list
start:
    @echo "🚀 Starting..."
JUST
    echo "✨ Created $n"
    cd "$p"
}

function work() {
    local n="$1"
    if [ -z "$n" ]; then
        n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="🚀 Work > " --layout=reverse)
        [ -z "$n" ] && return 1
    fi
    local p="$HOME/PARA/1_Projects/$n/💻_Code"
    [ ! -d "$p" ] && echo "❌ Not found" && return 1
    echo "🚀 Launching $n..."
    cd "$p"
    if command -v zellij >/dev/null; then
        eval "zellij --session \"$n\" --layout \"$HOME/dotfiles/config/zellij/layouts/cockpit.kdl\""
    else
        code .
    fi
}

function finish-work() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then echo "❌ Not a git repo."; return 1; fi
    gcm
    echo "☁️ Pushing..."
    git push
    gum style --foreground 82 "🎉 Done."
}

function snapshot() {
    local root=$(git rev-parse --show-toplevel 2>/dev/null); [ -z "$root" ] && return 1
    local dest="$root/.snapshots/snap_$(date "+%Y%m%d_%H%M%S")"
    mkdir -p "$dest"
    rsync -av --exclude '.git' --exclude '.snapshots' --exclude 'node_modules' "$root/" "$dest/" >/dev/null
    echo "📸 Snapshot saved."
}

function restore-snapshot() {
    local root=$(git rev-parse --show-toplevel 2>/dev/null); [ -z "$root" ] && return 1
    local snap_dir="$root/.snapshots"
    [ ! -d "$snap_dir" ] && echo "❌ No snapshots." && return 1
    local target=$(ls "$snap_dir" | fzf --prompt="🕰️ Restore > ")
    [ -n "$target" ] && gum confirm "Overwrite?" && rsync -av "$snap_dir/$target/" "$root/" >/dev/null && echo "✅ Restored."
}
alias w="work"
alias m="mkproj"
alias f="finish-work"
alias snap="snapshot"
