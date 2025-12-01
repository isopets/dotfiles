# =================================================================
# 🧠 AI Augmentation (Gemini 2.0 Flash) - PRODUCTION READY
# =================================================================

function _call_gemini() {
    local prompt="$1"
    
    if [ -z "$GEMINI_API_KEY" ]; then echo "❌ Error: GEMINI_API_KEY is missing."; return 1; fi

    # モデルを 'gemini-2.0-flash' に指定
    local url="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY"
    
    # JSON作成
    local body=$(jq -n --arg q "$prompt" '{contents: [{parts: [{text: $q}]}]}')

    # APIリクエスト (ヘッダ情報を排除し、純粋なJSONのみ取得)
    local result=$(curl -s -X POST -H "Content-Type: application/json" -d "$body" "$url")
    
    # エラー判定
    if echo "$result" | grep -q "\"error\":"; then
        echo "❌ API Error:"
        echo "$result" | jq .error.message 2>/dev/null || echo "$result"
        return 1
    fi

    # 成功応答からテキストを抽出
    echo "$result" | jq -r '.candidates[0].content.parts[0].text'
}

function ask() {
    local q="$1"
    
    if [ -z "$q" ]; then echo "Usage: ai 'question'"; return 1; fi
    
    echo "🤖 Asking Gemini (2.0 Flash)..."

    local response=$(_call_gemini "$q")
    
    if [ -n "$response" ] && [ "$response" != "null" ]; then
        echo ""
        # gum format で Markdown を表示
        echo "$response" | gum format 2>/dev/null || echo "$response"
    else
        echo "❌ Empty or Unparseable Response."
    fi
}
# --- 他の関数 (gcm, explain-it) は一旦省略 ---
