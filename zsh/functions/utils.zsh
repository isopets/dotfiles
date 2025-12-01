# =================================================================
# 🛠️ Utility Functions (Health & Hygiene)
# =================================================================

# --- 🧹 Internal: File Integrity Check ---
function _self-clean-files() {
    local target_dirs=("$HOME/dotfiles/zsh/functions" "$HOME/dotfiles/zsh/config")
    for d in "${target_dirs[@]}"; do
        if [ -d "$d" ]; then
            for f in "$d"/*.zsh; do
                if [ -f "$f" ]; then
                    tr -cd '\11\12\40-\176' < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
                fi
            done
        fi
    done
}

# --- 🔄 Smart Reload ---
function sz() {
    echo "🧹 Cleaning environment..."
    _self-clean-files
    echo "🔄 Reloading Shell..."
    exec zsh
}

# --- 🚑 System Doctor (Enhanced) ---
function dot-doctor() {
    echo ""
    gum style --foreground 214 --bold --border double --padding "0 2" "🚑 COCKPIT HEALTH CHECK"
    echo ""
    
    local health=100

    # 1. Essential Tools Check
    echo "🔍 Checking Core Tools..."
    local tools=(fzf code nh direnv starship navi yazi)
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null; then
            echo "  ✅ $tool found"
        else
            echo "  ❌ $tool missing"
            health=50
        fi
    done

    # 2. Conflict Detector (Nix vs Brew)
    # Nixで管理すべきCLIツールが、Brewにも入っていないかチェック
    echo ""
    echo "🔍 Checking for Conflicts (Nix vs Brew)..."
    
    if command -v brew >/dev/null; then
        # チェック対象のCLIツールリスト (重複しがちなもの)
        local conflict_candidates=(
            navi yazi fzf bat eza zoxide direnv starship 
            lazygit jq ripgrep fd gnupg git gh
        )
        
        local found_conflict=0
        for pkg in "${conflict_candidates[@]}"; do
            # brew list でパッケージが存在するか確認 (静かに)
            if brew list --formula "$pkg" >/dev/null 2>&1; then
                echo "  ⚠️  Conflict: '$pkg' is installed in both Nix and Brew!"
                echo "     👉 Suggestion: brew uninstall $pkg"
                found_conflict=1
                health=80
            fi
        done
        
        if [ $found_conflict -eq 0 ]; then
            echo "  ✅ No conflicts found."
        fi
    else
        echo "  ℹ️  Homebrew not found (Skipping check)."
    fi

    echo ""
    if [ $health -eq 100 ]; then
        gum style --foreground 82 "✨ System is Perfectly Healthy."
    else
        gum style --foreground 196 "⚠️  System needs attention."
    fi
}

# --- 🧭 Contextual HUD ---
function guide() {
    echo ""
    gum style --foreground 214 --bold --border double --padding "0 2" "🧭 COCKPIT HUD"
    echo ""

    local doc_file="$HOME/dotfiles/zsh/cockpit_logic.zsh"
    local menu_items=$(awk '
        /^##/ { 
            sub(/^##[ \t]*/, ""); desc = $0; getline; 
            if ($0 ~ /^alias/) { sub(/^alias /, ""); sub(/=.*/, ""); printf "  %-10s : %s\n", $0, desc; }
            else if ($0 ~ /^function/) { sub(/^function /, ""); sub(/\(\).*/, ""); printf "  %-10s : %s\n", $0, desc; }
        }
    ' "$doc_file")

    echo "🔥 Available Actions:"
    echo "$menu_items"
    echo ""
    gum style --foreground 244 -- "=== Shortcuts ==="
    echo "  del <file> : Safe Delete"
    echo "  Ctrl+R     : History (Atuin)"
    echo "  Tab        : Completion (FZF)"
}

# --- 🧠 Second Brain ---
function brain() {
    local dir="$HOME/PARA/0_Inbox/Brain"
    mkdir -p "$dir"
    if [ "$1" = "new" ]; then
        echo -n "🧠 Title: "; read t
        local safe_t=$(echo "$t" | tr ' ' '_')
        code "$dir/$(date +%Y%m%d)_${safe_t}.md"
    else
        grep -r "" "$dir" 2>/dev/null | fzf --delimiter : --with-nth 1,3 --bind 'enter:execute(code {1})'
    fi
}
