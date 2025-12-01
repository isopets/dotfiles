# =================================================================
# 🧠 AI Augmentation (Gemini 2.0 Flash)
# =================================================================

function _call_gemini() {
    local prompt="$1"
    [ -z "$GEMINI_API_KEY" ] && echo "❌ Error: GEMINI_API_KEY is missing." && return 1

    local url="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY"
    local body=$(jq -n --arg q "$prompt" '{contents: [{parts: [{text: $q}]}]}')

    curl -s -X POST -H "Content-Type: application/json" -d "$body" "$url"
}

function ask() {
    local q="$1"
    [ -z "$q" ] && echo "Usage: ai 'question'" && return 1
    
    echo "🤖 Asking Gemini (2.0 Flash)..."
    local response=$(_call_gemini "$q")
    
    if echo "$response" | grep -q "\"error\":"; then
        echo "❌ API Error:"
        echo "$response" | jq .error.message 2>/dev/null || echo "$response"
    else
        local text=$(echo "$response" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null)
        if [ -n "$text" ] && [ "$text" != "null" ]; then
            echo ""; echo "$text" | gum format 2>/dev/null || echo "$text"
        else
            echo "❌ Empty response."; return 1
        fi
    fi
}

# コミットメッセージ生成
function gcm() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then echo "❌ Not a git repo."; return 1; fi
    git add .
    local diff=$(git diff --cached)
    [ -z "$diff" ] && echo "🍵 No changes." && return 0

    local msg=$(ask "Generate a concise git commit message (Conventional Commits) for:\n\n$diff" | head -n 1)
    if [ -n "$msg" ]; then
        gum confirm "Commit: '$msg'?" && git commit -m "$msg"
    fi
}

function explain-it() {
    [ -f "$1" ] && ask "Explain this code:\n\n$(cat $1)" || echo "Usage: explain-it <file>"
}
