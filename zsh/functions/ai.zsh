function ask() {
    check_gemini_key || return 1
    local r=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Command only: $1\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY");
    echo "$r" | jq -r '.candidates[0].content.parts[0].text'
}
function gcm() {
    check_gemini_key || return 1
    local d=$(git diff --cached); [ -z "$d" ] && return 1
    local m=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Git commit message for:\n$d\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text')
    echo "$m"; read -r -p "Commit? (y/n): " c; [ "$c" = "y" ] && git commit -m "$m"
}
function precmd() {
    local exit_code=$?
    if [ $exit_code -eq 0 ] || [ $exit_code -eq 130 ]; then return; fi
    if [ -z "$GEMINI_API_KEY" ]; then return; fi
    local last_cmd=$(fc -ln -1)
    if [[ ${#last_cmd} -lt 4 ]] || [[ "$last_cmd" == "cd"* ]]; then return; fi
    if [[ "$TERM_PROGRAM" == "Warp.app" ]]; then return; fi
    echo "\n🤖 Asking Gemini..."
    local fix=$(curl -s -H "Content-Type: application/json" -d "{ \"contents\": [{ \"parts\": [{ \"text\": \"Fix zsh command error. Output ONLY the corrected command.\nCommand: $last_cmd\" }] }] }" "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" | jq -r '.candidates[0].content.parts[0].text' | sed 's/`//g' | xargs)
    if [ -n "$fix" ] && [ "$fix" != "null" ]; then echo "💡 Suggestion: \033[1;32m$fix\033[0m"; print -z "$fix"; fi
}
