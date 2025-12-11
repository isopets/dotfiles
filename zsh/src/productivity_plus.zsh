# �� Cockpit Productivity Plus (Part 1/3)

function copen() {
    setopt local_options nullglob; local t="${1:-.}"; local d="$t"
    [ -f "$t" ] && d=$(dirname "$t")
    local p="[Base] Common"
    if [ -f "$d/.cockpit_profile" ]; then p=$(cat "$d/.cockpit_profile")
    elif [ -n "$(ls "$d"/*.py 2>/dev/null)" ]; then p="[Lang] Python"
    elif [ -f "$d/package.json" ]; then p="[Lang] Web"
    fi
    echo "🚀 Launching: $p"; command code --profile "$p" "$t"
}

function mkproj() {
    local n="$1"; [ -z "$n" ] && n=$(gum input --placeholder "Project Name")
    [ -z "$n" ] && return 1
    local p="$HOME/PARA/1_Projects/$n/_Code"
    mkdir -p "$p"; git init "$p" >/dev/null
    echo "# $name" > "$p/README.md"
    echo "✅ Created: $n"; copen "$p"
}

function mklang() {
    local l="$1"; [ -z "$l" ] && l=$(gum input --placeholder "Language")
    [ -z "$l" ] && return 1
    local p="[Lang] $l"; mkdir -p "$HOME/dotfiles/vscode/profiles/$p"
    echo "✅ Profile: $p"
}

function work() {
    local n="$1"
    [ -z "$n" ] && n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="🚀 Work > " --layout=reverse)
    [ -z "$n" ] && return 1
    local p="$HOME/PARA/1_Projects/$n/_Code"
    [ ! -d "$p" ] && echo "❌ 404" && return 1
    echo "🚀 $n"; copen "$p"
}

function daily() {
    local t=$(date +%Y-%m-%d); local f="$HOME/PARA/0_Inbox/Daily/${t}.md"
    mkdir -p "$(dirname "$f")"
    [ ! -f "$f" ] && echo "# Daily: $t\n\n## 📝 Log" > "$f"
    copen "$f"
}

function log() {
    local m="$*"; [ -z "$m" ] && return 1
    echo "- $(date +%H:%M) $m" >> "$HOME/PARA/0_Inbox/quick_notes.md"
    echo "📝 Logged."
}

function remember() {
    local u=$(pbpaste); [[ "$u" != http* ]] && echo "⚠️ No URL" && return 1
    echo "$u" >> ".cockpit_urls"; echo "📌 Saved: $u"
}

function ask() {
    [ -f "$HOME/dotfiles/scripts/ask_ai.py" ] && python3 "$HOME/dotfiles/scripts/ask_ai.py" "$*" || echo "AI Offline"
}

function nix-up() {
    [ -f "$HOME/dotfiles/scripts/cockpit-update.sh" ] && sudo "$HOME/dotfiles/scripts/cockpit-update.sh"
}

function load_secrets() {
    [ -n "$GEMINI_API_KEY" ] && return
    local k=$(gum input --password --placeholder "Gemini Key")
    [ -n "$k" ] && export GEMINI_API_KEY="$k" && echo "✅ Loaded"
}

function ambience() {
    local s=$(gum choose "🌧️ Rain" "🔥 Fire" "☕ Cafe" "🔇 Stop")
    pkill "afplay" 2>/dev/null
    case "$s" in
        *"Rain"*) open "https://mynoise.net/NoiseMachines/rainNoiseGenerator.php" ;;
        *"Fire"*) open "https://mynoise.net/NoiseMachines/fireNoiseGenerator.php" ;;
        *"Stop"*) echo "🔇" ;;
        *) echo "☕" ;;
    esac
}

function dashboard() {
    clear
    if command -v gum >/dev/null; then
        gum style --border double --align center --width 50 --padding "0 2" "Good Day, $USER." "Keep moving."
    else
        echo "👋 Good Day, $USER."
    fi
    local c=$(ls ~/PARA/0_Inbox 2>/dev/null | wc -l | xargs)
    echo "  📥 Inbox: $c items"
    echo "\n  🚀 Recent:"
    ls -dt ~/PARA/1_Projects/*/ 2>/dev/null | head -n 3 | while read l; do echo "     🔹 $(basename "$l")"; done
    echo ""
}

# Aliases
alias done="daily"
alias sk="load_secrets"
alias rem="remember"
alias l="log"
alias check="echo 'System OK'"
alias home="dashboard"
alias dev="dashboard"
