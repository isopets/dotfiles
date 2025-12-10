# =================================================================
# ❄️ Cockpit Nix Module (Final Fix)
# =================================================================

NIX_LOG="/tmp/cockpit_nix.log"
NIX_LOCK="/tmp/cockpit_nix.lock"
UPDATE_SCRIPT="$HOME/dotfiles/scripts/cockpit-update.sh"

function _sed_i() {
    if sed --version 2>/dev/null | grep -q GNU; then sed -i "$@"; else sed -i '' "$@"; fi
}

## 🚀 System Update
function nix-up() {
    # ロックファイルが残っていたら警告（強制削除は手動または再起動で）
    if [ -f "$NIX_LOCK" ]; then
        # プロセスが生きてるか確認、死んでたらロック削除して続行
        if ! pgrep -f "cockpit-update.sh" > /dev/null; then
             echo "🗑️  Removing stale lock file..."
             rm -f "$NIX_LOCK"
        else
             echo "⚠️  Update is already running!"
             return 1
        fi
    fi

    echo "🚀 Update started in background..."
    echo "📝 Logs: $NIX_LOG"
    
    (
        touch "$NIX_LOCK"
        echo "=== 🚀 Update Started at $(date) ===" > "$NIX_LOG"
        
        # Git Auto-commit (User権限)
        local dir="$HOME/dotfiles"
        if [ -n "$(git -C "$dir" status --porcelain)" ]; then
             echo "📦 Auto-committing config..." >> "$NIX_LOG"
             git -C "$dir" add . >> "$NIX_LOG" 2>&1
             git -C "$dir" commit -m "chore(nix): update config" >> "$NIX_LOG" 2>&1
        fi

        # Script Execution (Root権限 - darwin-rebuild)
        if sudo "$UPDATE_SCRIPT" >> "$NIX_LOG" 2>&1; then
            echo "✅ Success at $(date)" >> "$NIX_LOG"
            osascript -e 'display notification "System Updated 🚀" with title "Cockpit Ready"'
        else
            echo "❌ Failed at $(date)" >> "$NIX_LOG"
            tail -n 5 "$NIX_LOG" >> "$NIX_LOG"
            osascript -e 'display notification "Update Failed! Check logs ⚠️" with title "Cockpit Error"'
        fi
        
        rm -f "$NIX_LOCK"
        
    ) &! 
    
    return 0
}

## 👁️ Monitor: Mission HUD
function log-up() {
    local log_file="/tmp/cockpit_nix.log"
    [ ! -f "$log_file" ] && echo "📭 No logs." && return

    local viewer="tail -f"
    if command -v lnav >/dev/null; then viewer="lnav"; fi

    if [ -n "$ZELLIJ" ]; then
        zellij run --name "🛰️ Mission Log" --floating --width 85% --height 85% -- bash -c "$viewer '$log_file'"
    else
        eval "$viewer '$log_file'"
    fi
}

function nix-add() {
    local pkg="$1"; [ -z "$pkg" ] && pkg=$(gum input --placeholder "Package Name")
    [ -z "$pkg" ] && return 1
    _sed_i "/^  ];/i \\    $pkg" "$HOME/dotfiles/nix/pkgs.nix"
    echo "📝 Added '$pkg'"
    nix-up
}

function cask-add() {
    local pkg="$1"; [ -z "$pkg" ] && pkg=$(gum input --placeholder "App Name")
    [ -z "$pkg" ] && return 1
    local file="$HOME/dotfiles/nix/modules/darwin.nix"
    if grep -q "\"$pkg\"" "$file"; then echo "⚠️ '$pkg' exists."; return 1; fi
    _sed_i "/casks =/s/\];/ \"$pkg\" \];/" "$file"
    echo "📝 Added '$pkg'"
    nix-up
    echo "ℹ️  Installing in background..."
}

alias up="nix-up"
alias add="nix-add"
alias app="cask-add"
alias watch="log-up"

## 👁️ Monitor: Auto-Close Edition (Smart Watch)
function log-up() {
    local log_file="/tmp/cockpit_nix.log"
    
    if [ ! -f "$log_file" ]; then
        echo "📭 No logs found. Run 'up' first."
        return
    fi

    # 自動終了する監視コマンドを作成
    # 1. 最初からログを表示 (tail -n +1)
    # 2. 追記を監視 (-f)
    # 3. 成功/失敗の文字が出たらループを抜けて終了
    local smart_cmd="tail -n +1 -f '$log_file' | while read line; do echo \"\$line\"; if [[ \"\$line\" == *'✅ Success'* ]] || [[ \"\$line\" == *'❌ Failed'* ]]; then break; fi; done"

    # Zellijの中にいる場合
    if [ -n "$ZELLIJ" ]; then
        echo "🛰️  Opening Mission HUD (Auto-Close)..."
        # --close-on-exit: コマンドが終わったらペインも閉じる
        zellij run --name "🛰️ Mission Log" --floating --width 85% --height 85% --close-on-exit -- bash -c "$smart_cmd"
    else
        # Zellij外
        echo "👁️  Monitoring... (Auto-exit on finish)"
        bash -c "$smart_cmd"
    fi
}

# エイリアス
alias watch="log-up"

# 手動でじっくり見たい時用のコマンドも残しておく
alias analyze="lnav /tmp/cockpit_nix.log"
