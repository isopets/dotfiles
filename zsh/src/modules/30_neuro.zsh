# --- 30_neuro.zsh : Brain & Environment ---

function play() {
    local l="$1"; [ -z "$l" ] && l=$(gum input) && [ -z "$l" ] && return
    local d="Play_${l}_$(date +%H%M%S)"; local p="$HOME/PARA/0_Inbox/Playground/$d"
    mkdir -p "$p"; cd "$p"
    # Simplified logic for play
    touch scratch.txt; echo "🚀 Playground: $l"; copen .
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
alias dev="dashboard"
alias home="dashboard"
