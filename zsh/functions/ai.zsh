function ask() {
    local q="$1"
    [ -z "$q" ] && return 1
    [ -z "$GEMINI_API_KEY" ] && echo "❌ Key missing." && return 1
    
    local url="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY"
    local body=$(jq -n --arg q "$q" '{contents: [{parts: [{text: $q}]}]}')
    local res=$(curl -s -X POST -H "Content-Type: application/json" -d "$body" "$url")
    
    local text=$(echo "$res" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null)
    if [ -n "$text" ] && [ "$text" != "null" ]; then
        echo ""; echo "$text" | gum format 2>/dev/null || echo "$text"
    else
        echo "❌ Error."
    fi
}
