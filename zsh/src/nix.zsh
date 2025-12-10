NIX_LOG="/tmp/cockpit_nix.log"
NIX_LOCK="/tmp/cockpit_nix.lock"
UPDATE_SCRIPT="$HOME/dotfiles/scripts/cockpit-update.sh"
function nix-up() {
    if [ -f "$NIX_LOCK" ]; then
        pgrep -f "cockpit-update.sh" > /dev/null || rm -f "$NIX_LOCK"
        [ -f "$NIX_LOCK" ] && echo "⚠️ Update running!" && return 1
    fi
    echo "🚀 Update started..."
    (
        touch "$NIX_LOCK"
        echo "=== Update: $(date) ===" > "$NIX_LOG"
        local dir="$HOME/dotfiles"
        [ -n "$(git -C "$dir" status --porcelain)" ] && git -C "$dir" add . && git -C "$dir" commit -m "chore: update config" >> "$NIX_LOG" 2>&1
        if sudo "$UPDATE_SCRIPT" >> "$NIX_LOG" 2>&1; then
            osascript -e 'display notification "System Updated 🚀" with title "Cockpit"'
        else
            osascript -e 'display notification "Update Failed ⚠️" with title "Cockpit"'
        fi
        rm -f "$NIX_LOCK"
    ) &
    disown
}
function log-up() {
    [ ! -f "$NIX_LOG" ] && echo "📭 No logs." && return
    tail -f "$NIX_LOG"
}
function nix-add() {
    [ -z "$1" ] && return 1
    sed -i '' "/^  ];/i \\    $1" "$HOME/dotfiles/nix/pkgs.nix"
    echo "📝 Added $1"
    nix-up
}
alias up="nix-up"
alias add="nix-add"
alias watch="log-up"
