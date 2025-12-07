# =================================================================
# 🤖 AI Logic Module (Gemini 2.0 Flash)
# =================================================================

function _call_gemini() {
    local prompt="$1"
    
    # 1. Secret Check
    if [ -z "$GEMINI_API_KEY" ]; then
        load_secrets >/dev/null
    fi
    if [ -z "$GEMINI_API_KEY" ]; then
        echo "❌ Error: GEMINI_API_KEY not found. Run 'sk' to save it." >&2
        return 1
    fi

    # 2. Prepare Payload (Robust JSON construction)
    local url="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY"
    local body
    # jqを使って安全にJSONを生成
    body=$(jq -n --arg q "$prompt" '{contents: [{parts: [{text: $q}]}]}')

    # 3. API Call
    local res
    res=$(curl -s -X POST -H "Content-Type: application/json" -d "$body" "$url")

    # 4. Response Validation
    if [ -z "$res" ]; then
        echo "❌ Error: Empty response from API." >&2
        return 1
    fi

    # API側がエラーJSONを返した場合
    if echo "$res" | grep -q '"error":'; then
        echo "❌ API Error:" >&2
        echo "$res" | jq -r '.error.message // .' >&2
        return 1
    fi

    # 5. Extract Content (No hiding errors)
    local answer
    # printfを使って安全にパイプに渡す
    answer=$(printf '%s' "$res" | jq -r '.candidates[0].content.parts[0].text')
    
    # jqの実行自体が失敗した場合
    if [ $? -ne 0 ]; then
        echo "❌ jq Error: Failed to parse JSON response." >&2
        echo "--- Raw Response Start ---" >&2
        echo "$res" >&2
        echo "--- Raw Response End ---" >&2
        return 1
    fi

    # 抽出結果が空の場合
    if [ -z "$answer" ] || [ "$answer" = "null" ]; then
        echo "❌ Parse Error: Extracted text is empty." >&2
        echo "--- Raw Response Start ---" >&2
        echo "$res" >&2
        echo "--- Raw Response End ---" >&2
        return 1
    fi

    echo "$answer"
}

function ask() {
    local q="$*"
    if [ -z "$q" ]; then
        echo "Usage: ask <question>"
        return 1
    fi

    echo "🤖 Asking Gemini..."
    local res
    res=$(_call_gemini "$q")

    if [ $? -eq 0 ] && [ -n "$res" ]; then
        echo ""
        # gumが使えるならMarkdown整形して表示
        if command -v gum >/dev/null; then
            echo "$res" | gum format
        else
            echo "$res"
        fi
    fi
}

# --- Context Aware Wrappers ---

function gcm() {
    if [ ! -d .git ]; then
        echo "⚠️ Not a git repository."
        return 1
    fi

    git add .
    local diff
    diff=$(git diff --cached --name-only)
    
    if [ -z "$diff" ]; then
        echo "⚠️ No changes to commit."
        return 0
    fi
    
    # 変更内容の統計情報を取得
    local stats
    stats=$(git diff --cached --stat)
    
    local msg
    msg=$(ask "Generate a conventional commit message (e.g., feat: ..., fix: ...) for these changes. Output ONLY the message text.\n\nChanges:\n$stats")
    
    if [ $? -eq 0 ]; then
        echo "--------------------------------"
        echo "$msg"
        echo "--------------------------------"
        if gum confirm "Commit with this message?"; then
            git commit -m "$msg"
        else
            echo "❌ Cancelled."
        fi
    fi
}

function ask-project() {
    local q="$1"
    if [ -z "$q" ]; then
        echo "Usage: ap 'question'"
        return 1
    fi
    
    echo "📂 Reading file structure..."
    local structure
    if command -v eza >/dev/null; then
        structure=$(eza --tree --level=2 -I ".git|node_modules|.DS_Store")
    else
        structure=$(ls -R)
    fi
    
    ask "You are an expert developer. Answer the question based on this project structure:\n\n$structure\n\nQuestion: $q"
}

# Aliases
alias a="ask"
alias ai="ask"
alias ap="ask-project"
