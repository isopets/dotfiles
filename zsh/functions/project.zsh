# =================================================================
# 📂 Project Management (Intent-Driven & Visual)
# =================================================================

# --- 1. Project Creation ---
function mkproj() {
    local c="$1"; local n="$2"

    # Category Selection
    if [ -z "$c" ]; then
        local categories=$(ls -F "$REAL_CODE_DIR" 2>/dev/null | grep "/" | tr -d "/" )
        [ -z "$categories" ] && categories="Personal\nWork\nSandbox\nLearning" || categories="${categories}\nPersonal\nWork\nSandbox\nLearning"
        c=$(echo -e "$categories" | awk '!seen[$0]++' | fzf --prompt="📂 Select Category > " --height=40% --layout=reverse)
        if [ -z "$c" ]; then echo "👋 Canceled."; return 1; fi
    fi

    # Name Input
    if [ -z "$n" ]; then
        echo -n "📛 Project Name: "; read n
        if [ -z "$n" ]; then echo "❌ Name is required."; return 1; fi
    fi

    # Implementation
    local p="$REAL_CODE_DIR/$c/$n"
    local a="$REAL_ASSETS_DIR/$c/$n"
    local para="$PARA_DIR/1_Projects/$n"

    if [ -d "$p" ]; then echo "❌ Project '$n' already exists."; return 1; fi

    echo "🏗️  Constructing Virtual PARA..."
    mkdir -p "$p/.vscode" "$a"/{Design,Video,Export} "$para"
    ln -s "$a" "$p/_GoToCreative"; ln -s "$p" "$a/_GoToCode"
    ln -s "$p" "$para/💻_Code"; ln -s "$a" "$para/🎨_Assets"

    git -C "$p" init; echo "# $n" > "$p/README.md"
    touch "$p/.env"; echo "dotenv" > "$p/.envrc"

    # Profile Selection
    local profile_list_file="$HOME/dotfiles/vscode/profile_list.txt"
    [ ! -f "$profile_list_file" ] && echo "[Base] Common\n[Lang] Python\n[Lang] Web" > "$profile_list_file"
    local selected_profile=$(cat "$profile_list_file" | fzf --prompt="🐍 Select VS Code Profile > " --height=40%)
    [ -n "$selected_profile" ] && echo "PROFILE=$selected_profile" > "$p/.vscode/cockpit.env"

    # Finalize
    git -C "$p" add .; git -C "$p" commit -m "feat: Init project '$n'"
    
    echo ""; gum style --foreground 82 "✨ Project Created!"
    if command -v eza &>/dev/null; then eza --tree --level=2 --icons --color=always "$para"; else ls -R "$para"; fi
    echo ""
    cd "$p"; if command -v direnv &>/dev/null; then direnv allow .; fi
}

# --- 2. Start Work ---
function work() {
    local n="$1"
    if [ -z "$1" ]; then
        n=$(ls "$PARA_DIR/1_Projects" 2>/dev/null | fzf --prompt="🚀 Select Project > " --height=50% --layout=reverse)
        if [ -z "$n" ]; then return 1; fi
    fi
    
    local p="$PARA_DIR/1_Projects/$n"
    local r=$(readlink "$p/💻_Code")
    
    if [ -d "$r" ]; then
        echo "🚀 Launching: $n"
        
        # Profile Load
        local cockpit_env="$r/.vscode/cockpit.env"
        local profile_arg=""
        if [ -f "$cockpit_env" ]; then
            source "$cockpit_env"
            [ -n "$PROFILE" ] && profile_arg="--profile \"$PROFILE\"" && export COCKPIT_VSCODE_PROFILE="$PROFILE"
        fi

        # Asset Open
        local asset_path=$(readlink "$p/🎨_Assets")
        if [ -d "$asset_path" ]; then open "$asset_path"; fi
        
        # Log
        mkdir -p "$r/docs"
        local log="$r/docs/DEV_LOG.md"
        [ ! -f "$log" ] && echo "# Dev Log: $n" > "$log"
        echo "\n## $(date '+%Y-%m-%d %H:%M') - Session Start" >> "$log"
        
        cd "$r"; eval "code --wait $profile_arg \"$r\" \"$log\""
    else
        echo "❌ Directory not found."
    fi
}

# --- 3. Finish Work (AI Closer) ---
function finish-work() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then echo "❌ Not a git repo."; return 1; fi
    
    echo "🏁 Closing session..."
    local log_file="./docs/DEV_LOG.md"
    mkdir -p "./docs"
    
    git add .
    local diff=$(git diff --cached --stat)
    local diff_details=$(git diff --cached)

    if [ -z "$diff" ]; then echo "🍵 No changes."; return 0; fi

    local commit_msg="chore: save work"
    local work_summary="- Work saved (Manual)"

    if [ -n "$GEMINI_API_KEY" ]; then
        echo "🤖 AI Generating summary..."
        local prompt="Based on diff, generate: 1. commit message. 2. 3-point summary. Output JSON: { \"commit\": \"...\", \"summary\": \"- ...\" }\n\nDiff:\n$diff_details"
        local res=$(curl -s -H "Content-Type: application/json" \
            -d "{ \"contents\": [{ \"parts\": [{ \"text\": $(echo "$prompt" | jq -R -s .) }] }] }" \
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY" \
            | jq -r '.candidates[0].content.parts[0].text' | sed 's/```json//g' | sed 's/```//g')
        
        local ai_commit=$(echo "$res" | jq -r '.commit' 2>/dev/null)
        local ai_summary=$(echo "$res" | jq -r '.summary' 2>/dev/null)
        
        [ -n "$ai_commit" ] && [ "$ai_commit" != "null" ] && commit_msg="$ai_commit"
        [ -n "$ai_summary" ] && [ "$ai_summary" != "null" ] && work_summary="$ai_summary"
    fi

    if [ -f "$log_file" ]; then
        echo -e "\n### 🍵 Session End ($(date '+%H:%M'))\n$work_summary" >> "$log_file"
    fi

    echo -e "\n💬 Commit: \033[1;32m$commit_msg\033[0m"
    if gum confirm "Push?"; then
        git commit -m "$commit_msg"; git push
        gum style --foreground 82 "🎉 Done."
    else
        echo "⚠️ Staged only."
    fi
}

# --- 4. Scratchpad (New!) ---
function scratch() {
    local timestamp=$(date "+%Y%m%d_%H%M%S")
    local scratch_dir="$HOME/PARA/0_Inbox/Scratch/$timestamp"
    
    # Language Selection
    local lang=$(echo "Plain\nPython\nWeb\nMarkdown" | fzf --prompt="📝 Select Mode > " --height=30%)
    if [ -z "$lang" ]; then return 1; fi

    mkdir -p "$scratch_dir"
    
    # テンプレート作成
    case "$lang" in
        "Python") echo "print('Hello Scratch')" > "$scratch_dir/main.py" ;;
        "Web") echo "<html><body><h1>Hello</h1></body></html>" > "$scratch_dir/index.html" ;;
        "Markdown") echo "# Scratchpad" > "$scratch_dir/note.md" ;;
        *) echo "Type here..." > "$scratch_dir/scratch.txt" ;;
    esac

    echo "🚀 Opening Scratchpad ($lang)..."
    code "$scratch_dir"
}

alias done="finish-work"
function archive() { echo "📦 Archive logic needed."; }
