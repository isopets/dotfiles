#!/bin/zsh
echo "🔧 Starting Cockpit Repair..."

# --- A. Repair .zshrc (Simple & Safe) ---
echo 'export DOTFILES="$HOME/dotfiles"' > ~/.zshrc
echo 'export PATH="$HOME/.nix-profile/bin:$PATH"' >> ~/.zshrc
echo 'setopt +o nomatch' >> ~/.zshrc
echo '[ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"' >> ~/.zshrc
echo 'for f in "$DOTFILES/zsh/functions/"*.zsh; do source "$f"; done' >> ~/.zshrc
echo 'alias ai="ask"' >> ~/.zshrc
echo 'command -v starship >/dev/null && eval "$(starship init zsh)"' >> ~/.zshrc
echo 'command -v direnv >/dev/null && eval "$(direnv hook zsh)"' >> ~/.zshrc
echo "✅ .zshrc repaired."

# --- B. Repair ai.zsh (Gemini Pro / Robust Error Handling) ---
cat << 'AI_END' > ~/dotfiles/zsh/functions/ai.zsh
function ask() {
    local q="$1"
    if [ -z "$q" ]; then echo "Usage: ai 'question'"; return 1; fi
    if [ -z "$GEMINI_API_KEY" ]; then echo "❌ Error: GEMINI_API_KEY is missing in .env"; return 1; fi

    echo "🤖 Asking Gemini..."
    # 安定版の gemini-pro を使用
    local url="https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$GEMINI_API_KEY"
    
    # JSON構築 (jqを使用しエスケープ問題を回避)
    local body=$(jq -n --arg q "$q" '{contents: [{parts: [{text: $q}]}]}')

    # APIコール
    local result=$(curl -s -X POST -H "Content-Type: application/json" -d "$body" "$url")

    # 結果判定
    if echo "$result" | grep -q "\"error\":"; then
        echo "❌ API Error:"
        echo "$result" | jq .error.message 2>/dev/null || echo "$result"
    else
        local text=$(echo "$result" | jq -r '.candidates[0].content.parts[0].text')
        if [ "$text" = "null" ]; then
            echo "❌ Unexpected response (null)."
            echo "$result"
        else
            echo ""
            echo "$text" | gum format 2>/dev/null || echo "$text"
        fi
    fi
}
AI_END
echo "✅ ai.zsh repaired."

echo "🎉 Repair Complete. Run 'source ~/.zshrc' now."
