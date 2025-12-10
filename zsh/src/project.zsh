## =================================================================
## 🚀 Project Manager (Browser Launcher & Bookmark Edition)
## =================================================================

## Work Mode (Ultimate Context Switch)
function work() {
    local n="$1"
    
    # 1. プロジェクト選択
    if [ -z "$n" ]; then
        n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="🚀 Work > " --layout=reverse)
        [ -z "$n" ] && return 1
    fi
    
    local p="$HOME/PARA/1_Projects/$n/_Code"
    [ ! -d "$p" ] && echo "❌ Not found" && return 1
    
    echo "🚀 Launching Cockpit: $n"
    
    # 2. ブラウザの自動起動 (バックグラウンド)
    (
        cd "$p"
        # 登録済みURLがあれば開く
        if [ -f ".cockpit_urls" ]; then
            # 空行とコメントを除外して開く
            grep -vE '^\s*#|^\s*$' ".cockpit_urls" | xargs open
        
        # なければGitHubを探して開く
        elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            local repo_url=$(git remote get-url origin 2>/dev/null | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
            if [ -n "$repo_url" ]; then
                open "$repo_url"
            fi
        fi
    ) &

    # 3. エディタ/ターミナル起動
    cd "$p"
    if command -v zellij >/dev/null; then
        zellij attach "$n" 2>/dev/null || \
        eval "zellij --session \"$n\" --layout \"$HOME/dotfiles/config/zellij/layouts/cockpit.kdl\""
    else
        code .
    fi
}

## 📌 Remember URL (クリップボードのURLをプロジェクトに登録)
function remember() {
    # 現在のプロジェクトルートを探す
    local root=""
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        root=$(git rev-parse --show-toplevel)
    else
        # Git管理外ならカレントディレクトリ
        root=$(pwd)
    fi
    
    local url_file="$root/.cockpit_urls"
    
    # クリップボードからURLを取得 (pbpaste)
    local url=$(pbpaste)
    
    # URLっぽいか簡易チェック
    if [[ "$url" != http* ]]; then
        echo "⚠️  Clipboard does not contain a URL."
        echo "📋 Content: $url"
        return 1
    fi
    
    echo "$url" >> "$url_file"
    echo "📌 Remembered: $url"
    echo "   (Added to $url_file)"
}

# ... (以下の mkproj, sync-config 等の関数は前回のまま維持) ...
# ※ mkprojなどが消えないよう、本来はここに追加する形ですが、
#    今回は work と remember を上書き追加するイメージで捉えてください。
#    もし project.zsh 全体を書き換える場合は、以前の mkproj 等も含める必要があります。

# Aliases
alias w="work"
alias rem="remember" # 短縮コマンド
