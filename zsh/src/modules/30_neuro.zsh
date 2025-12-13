# --- 30_neuro.zsh (Safe Mode) ---

function play() {
    local l="$1"
    if [ -z "$l" ]; then
        l="python"
    fi
    
    local d="Play_$(date +%H%M%S)"
    local p="$HOME/PARA/0_Inbox/Playground/$d"
    mkdir -p "$p"
    cd "$p"
    touch scratch.txt
    echo "🚀 Playground created."
}

function dashboard() {
    clear
    echo "👋 Good Day, $USER."
    echo ""
    
    if [ -d "$HOME/PARA/0_Inbox" ]; then
        local c=$(ls "$HOME/PARA/0_Inbox" | wc -l | xargs)
        echo "  📥 Inbox: $c"
    fi
    
    echo ""
    echo "  👉 Type 'mk' for new project."
    echo ""
}

alias dev="dashboard"
alias home="dashboard"
alias bgm="echo '🎵 BGM feature is temporarily disabled.'"