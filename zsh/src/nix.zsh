# =================================================================
# ❄️ Cockpit Nix Module (Control Tower Edition)
# =================================================================

# --- Constants ---
NIX_LOG="/tmp/cockpit_nix.log"
NIX_LOCK="/tmp/cockpit_nix.lock"

function _sed_i() {
    if sed --version 2>/dev/null | grep -q GNU; then sed -i "$@"; else sed -i '' "$@"; fi
}

## 🚀 System Update (Background with Observability)
function nix-up() {
    # 1. 重複実行の防止
    if [ -f "$NIX_LOCK" ]; then
        echo "⚠️  Update is already running!"
        echo "👉 Run 'log-up' to see progress."
        return 1
    fi

    echo "🚀 Update started in background..."
    echo "📝 Logs: $NIX_LOG"
    echo "👁️  Watch: Run 'log-up' to monitor live."

    # 2. バックグラウンド処理開始
    (
        # ロック作成
        touch "$NIX_LOCK"
        
        # PATH設定
        export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.nix-profile/bin:$PATH"
        local dir="$HOME/dotfiles"
        
        # ログヘッダー
        echo "=== 🚀 Update Started at $(date) ===" > "$NIX_LOG"
        
        # Git Auto-commit
        if [ -n "$(git -C "$dir" status --porcelain)" ]; then
            echo "📦 Auto-committing config..." >> "$NIX_LOG"
            git -C "$dir" add . >> "$NIX_LOG" 2>&1
            git -C "$dir" commit -m "chore(nix): update config via cockpit" >> "$NIX_LOG" 2>&1
        fi

        # Update Execution
        echo "🔄 Rebuilding Darwin system..." >> "$NIX_LOG"
        if nh darwin switch "$dir" >> "$NIX_LOG" 2>&1; then
            echo "✅ Success at $(date)" >> "$NIX_LOG"
            osascript -e 'display notification "System Updated Successfully 🚀" with title "Cockpit Ready"'
        else
            echo "❌ Failed at $(date)" >> "$NIX_LOG"
            echo "---------------------------------------------------" >> "$NIX_LOG"
            echo "⚠️  ERROR DETAILS (Last 5 lines):" >> "$NIX_LOG"
            tail -n 5 "$NIX_LOG" >> "$NIX_LOG"
            
            osascript -e 'display notification "Update Failed! Check logs with `log-up` ⚠️" with title "Cockpit Error"'
        fi
        
        # ロック解除
        rm -f "$NIX_LOCK"
        
    ) &! 
    
    return 0
}

## 👁️ Monitor: ライブログ監視 (Ctrl+Cで抜ける)
function log-up() {
    if [ ! -f "$NIX_LOG" ]; then
        echo "📭 No logs found. Run 'nix-up' first."
        return
    fi
    
    echo "👁️  Monitoring Nix Update... (Ctrl+C to exit)"
    echo "---------------------------------------------"
    # tail -f でリアルタイム表示
    tail -f "$NIX_LOG"
}

## 🚦 Status: 今の状態を確認
function status-up() {
    echo "🚦 Cockpit System Status"
    echo "-----------------------"
    
    if [ -f "$NIX_LOCK" ]; then
        echo "🔄 State: RUNNING (Background)"
        echo "⏳ Started: $(stat -f "%Sm" "$NIX_LOCK")"
    else
        echo "✅ State: IDLE"
    fi
    
    if [ -f "$NIX_LOG" ]; then
        local last_line=$(tail -n 1 "$NIX_LOG")
        echo "📝 Last Log: $last_line"
    fi
    
    echo ""
    echo "👉 Use 'log-up' to see full details."
}


## Add CLI Tool
function nix-add() {
    local pkg="$1"; [ -z "$pkg" ] && pkg=$(gum input --placeholder "CLI Package Name")
    [ -z "$pkg" ] && return 1
    _sed_i "/^  ];/i \\    $pkg" "$HOME/dotfiles/nix/pkgs.nix"
    echo "📝 Added '$pkg' to pkgs.nix"
    nix-up
}

## Add App/Font
function cask-add() {
    local force_trust=false
    local pkg=""
    for arg in "$@"; do
        if [[ "$arg" == "-y" || "$arg" == "--yes" ]]; then force_trust=true
        elif [[ -z "$pkg" ]]; then pkg="$arg"; fi
    done
    [ -z "$pkg" ] && pkg=$(gum input --placeholder "App Name")
    [ -z "$pkg" ] && return 1

    local file="$HOME/dotfiles/nix/modules/darwin.nix"
    if grep -q "\"$pkg\"" "$file"; then echo "⚠️ '$pkg' exists."; return 1; fi

    echo "📝 Adding '$pkg' to darwin.nix..."
    _sed_i "/casks =/s/\];/ \"$pkg\" \];/" "$file"
    
    nix-up
    
    echo "ℹ️  Installation running in background."
    echo "    Type 'log-up' to watch progress."
    echo "    If warning appears later, run: allow $pkg"
}

# Aliases
alias up="nix-up"
alias add="nix-add"
alias app="cask-add"
alias watch="log-up"   # 短いエイリアス
alias st="status-up"   # ステータス確認
