function _call_gemini() {
    local prompt="$1"
    [ -z "$GEMINI_API_KEY" ] && load_secrets
    [ -z "$GEMINI_API_KEY" ] && echo "❌ Key missing." >&2 && return 1

    local url="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY"
    local body=$(jq -n --arg q "$prompt" '{contents: [{parts: [{text: $q}]}]}')
    local response=$(curl -s -X POST -H "Content-Type: application/json" -d "$body" "$url")
    
    if echo "$response" | grep -q '"error":'; then
        echo "❌ API Error:" >&2; echo "$response" | jq . >&2; return 1
    fi
    echo "$response" | jq -r '.candidates[0].content.parts[0].text'
}

function ask() {
    local q="$*"; [ -z "$q" ] && echo "Usage: ask 'q'" && return 1
    echo "🤖 Asking Gemini..."
    local res=$(_call_gemini "$q")
    [ -n "$res" ] && echo "" && echo "$res" | gum format 2>/dev/null || echo "$res"
}

function gcm() {
    [ ! -d .git ] && echo "❌ Not a git repo" && return 1
    git add .
    local diff=$(git diff --cached)
    [ -z "$diff" ] && echo "�� No changes." && return 0
    local msg=$(ask "Generate a conventional commit message for:\n$diff" | head -n 1)
    echo "💬 $msg"
    gum confirm "Commit?" && git commit -m "$msg"
}

function ask-project() {
    local q="$1"; [ -z "$q" ] && echo "Usage: ask-project 'q'" && return 1
    ! git rev-parse --is-inside-work-tree >/dev/null 2>&1 && echo "❌ Not a git repo" && return 1
    echo "🤖 Reading codebase..."
    local context=$(git ls-files | xargs -I {} sh -c 'file -b --mime-type "{}" | grep -q "text" && echo "\n--- {} ---\n" && cat "{}"' 2>/dev/null)
    [ -z "$context" ] && echo "❌ No text files." && return 1
    ask "Answer based on codebase:\n\nQuestion: $q\n\nCode:\n$context"
}
alias a="ask"
alias ai="ask"
alias ap="ask-project"
