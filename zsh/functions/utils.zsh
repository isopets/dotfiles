# =================================================================
# 🛠️ Utility Functions (Core System)
# =================================================================

function sz() {
    echo "🔄 Re-spawning Shell Process..."
    # source ではなく exec を使うことで、プロセスごと新品に入れ替える
    # これにより、VS Code上でも「ターミナル再起動」と同じ効果が得られる
    exec zsh
}

function rules() {
    echo "📖 Opening Manual..."
    code ~/dotfiles/docs/WORKFLOW.md
}

function dot-doctor() {
    echo "🚑 Cockpit System Diagnosis..."
    local health=100
    
    # 簡易チェック
    if command -v fzf >/dev/null; then echo "  ✅ fzf found"; else echo "  ❌ fzf missing"; health=50; fi
    if command -v code >/dev/null; then echo "  ✅ code found"; else echo "  ❌ code missing"; health=50; fi
    
    if [ $health -eq 100 ]; then
        echo "✨ System Healthy."
    else
        echo "⚠️ System Check Failed."
    fi
}
