function check_gemini_key() {
    if [ -n "$GEMINI_API_KEY" ]; then return 0; fi
    unlock-bw || return 1
    echo "🤖 Searching Bitwarden..."
    local ap=$(bw get password "Gemini-API-Key" 2>/dev/null)
    if [ -n "$ap" ]; then
        echo "export GEMINI_API_KEY=\"$ap\"" >> "$HOME/dotfiles/zsh/.zsh_secrets"
        source "$HOME/dotfiles/zsh/.zsh_secrets"
        return 0
    fi
    echo "⚠️ Key not found."
    return 1
}

function ask() {
    check_gemini_key || return 1
    local q="$1"
    if [ -z "$q" ]; then echo "Usage: ask 'Question'"; return 1; fi
    
    local hash=$(echo "$q" | md5)
    local cache_file="$AI_CACHE_DIR/$hash.txt"
    if [ -f "$cache_file" ]; then echo "⚡️ Cached:"; cat "$cache_file"; return 0; fi
    
    echo "🤖 Asking..."
    local r=$(curl -s -H "Content-Type: application/json" \
        -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Command only: $q\" }] }] }" \
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY")
    local ans=$(echo "$r" | jq -r '.candidates[0].content.parts[0].text')
    
    if [ -n "$ans" ] && [ "$ans" != "null" ]; then
        echo "$ans" | tee "$cache_file"
    else
        echo "❌ Error: $r"
    fi
}

function gcm() {
    check_gemini_key || return 1
    local d=$(git diff --cached)
    if [ -z "$d" ]; then echo "❌ No changes."; return 1; fi
    local m=$(curl -s -H "Content-Type: application/json" \
        -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Git commit message for:\n$d\" }] }] }" \
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
        | jq -r '.candidates[0].content.parts[0].text')
    echo "$m"
    read -r -p "Commit? (y/n): " c
    if [ "$c" = "y" ]; then git commit -m "$m"; fi
}

function explain-it() {
    check_gemini_key || return 1
    local file="$1"; [ ! -f "$file" ] && return 1
    echo "🤖 Explaining..."
    local content=$(cat "$file")
    local prompt="Add Japanese comments to explain the code logic. Output full code."
    local res=$(curl -s -H "Content-Type: application/json" \
        -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"$prompt\n\n$content\" }] }] }" \
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
        | jq -r '.candidates[0].content.parts[0].text' | sed 's/^```.*//' | sed 's/```$//')
    if [ -n "$res" ]; then cp "$file" "$file.bak"; echo "$res" > "$file"; echo "✅ Done."; code "$file"; else echo "❌ Failed."; fi
}

function precmd() {
    local exit_code=$?
    if [ $exit_code -eq 0 ] || [ $exit_code -eq 130 ]; then return; fi
    if [ -z "$GEMINI_API_KEY" ]; then return; fi
    local last_cmd=$(fc -ln -1)
    if [[ ${#last_cmd} -lt 4 ]] || [[ "$last_cmd" == "cd"* ]]; then return; fi
    if [[ "$TERM_PROGRAM" == "Warp.app" ]]; then return; fi
    
    echo "\n🤖 AI Analyzing..."
    local fix=$(curl -s -H "Content-Type: application/json" \
        -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Fix zsh command error. Output ONLY the corrected command string, no markdown.\nCommand: $last_cmd\" }] }] }" \
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
        | jq -r '.candidates[0].content.parts[0].text' | sed 's/`//g' | xargs)
    
    if [ -n "$fix" ] && [ "$fix" != "null" ]; then
        echo "💡 Suggestion: \033[1;32m$fix\033[0m"
        print -z "$fix"
    fi
}