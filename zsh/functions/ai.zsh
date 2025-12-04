function _call_gemini() {
    local prompt="$1"
    [ -z "$GEMINI_API_KEY" ] && echo "❌ Key missing." && return 1
    local url="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY"
    local body=$(jq -n --arg q "$prompt" '{contents: [{parts: [{text: $q}]}]}')
    curl -s -X POST -H "Content-Type: application/json" -d "$body" "$url" | jq -r '.candidates[0].content.parts[0].text'
}

function _call_ollama() {
    local prompt="$1"
    ! pgrep -x "ollama" > /dev/null && ollama serve > /dev/null 2>&1 & sleep 2
    ollama run phi3 "$prompt"
}

function ask() {
    local mode="cloud"; local q=""
    if [ "$1" = "-l" ]; then mode="local"; shift; fi
    q="$*"
    [ -z "$q" ] && echo "Usage: ask [-l] 'q'" && return 1

    if [ "$mode" = "local" ]; then
        echo "🦙 Asking Local (Phi3)..."
        _call_ollama "$q" | gum format
    else
        echo "🤖 Asking Gemini..."
        local res=$(_call_gemini "$q")
        echo "$res" | gum format
    fi
}
