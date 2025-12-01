# =================================================================
# 🧠 AI Augmentation (Gemini 2.0 Flash) - PRODUCTION READY
# =================================================================

# トークンログファイルのパス
API_USAGE_LOG="$HOME/.cache/cockpit_api_usage.log"

function _call_gemini() {
    local prompt="$1"
    
    if [ -z "$GEMINI_API_KEY" ]; then echo "❌ Error: GEMINI_API_KEY is missing."; return 1; fi

    local model="gemini-2.0-flash"
    local url="https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=$GEMINI_API_KEY"
    local body=$(jq -n --arg q "$prompt" '{contents: [{parts: [{text: $q}]}]}')

    # APIリクエスト
    local result=$(curl -s -X POST -H "Content-Type: application/json" -d "$body" "$url")

    # エラー判定
    if echo "$result" | grep -q "\"error\":"; then
        echo "❌ API Error:"
        echo "$result" | jq .error.message 2>/dev/null || echo "$result"
        return 1
    fi
    
    # --- NEW: トークン使用量の抽出と記録 ---
    local token_count=$(echo "$result" | jq -r '.usageMetadata.totalTokenCount')
    local input_tokens=$(echo "$result" | jq -r '.usageMetadata.promptTokenCount')
    
    if [ -n "$token_count" ] && [ "$token_count" != "null" ]; then
        mkdir -p "$HOME/.cache"
        # ログ形式: timestamp model total_tokens input_tokens
        echo "$(date +%s) $model $token_count $input_tokens" >> "$API_USAGE_LOG"
    fi
    # --------------------------------------

    local text=$(echo "$result" | jq -r '.candidates[0].content.parts[0].text')
        
    if [ -n "$text" ] && [ "$text" != "null" ]; then
        echo "$text"
    else
        echo "❌ Empty or Unparseable Response."
    fi
}

function ask() {
    local q="$1"
    if [ -z "$q" ]; then echo "Usage: ai 'question'"; return 1; fi
    
    echo "🤖 Asking Gemini (2.0 Flash)..."
    local response=$(_call_gemini "$q")
    
    if [ "$?" -eq 0 ]; then
        echo ""
        echo "$response" | gum format 2>/dev/null || echo "$response"
    fi
}

# --- gcm, explain-it などは省略 ---
