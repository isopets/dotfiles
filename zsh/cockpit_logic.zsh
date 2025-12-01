# =================================================================
# 🎮 Cockpit Logic (Live Editable & Auto-Docs)
# =================================================================

# --- 1. Safety First (Trash instead of Rm) ---
# 事故防止のため rm をブロックし、del (trash-put) を推奨
alias rm="echo '⛔️ Use \"del\" (trash) or \"/bin/rm\"'; false"
alias del="trash-put"

# --- 2. Unified Interface (Smart Edit) ---
function edit() {
    local file="${1:-.}"
    # ファイルが存在しない、またはサイズが大きい場合は VS Code
    if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
        gum style --foreground 33 "🚀 Launching VS Code..."
        code "$file"
    else
        # 小さなファイルは Neovim で瞬時に開く
        gum style --foreground 150 "⚡ Launching Neovim..."
        nvim "$file"
    fi
}

# --- 3. Auto-Generating Guide (The Magic HUD) ---
function guide() {
    echo ""
    gum style --foreground 214 --bold --border double --padding "0 2" "🧭 COCKPIT HUD (Auto-Generated)"
    echo ""

    # このファイル自身のコメント(##)を解析してマニュアル化
    local doc_file="$HOME/dotfiles/zsh/cockpit_logic.zsh"
    
    local menu_items=$(grep -B 1 "^[[:space:]]*alias\|^[[:space:]]*function" "$doc_file" | \
        grep -v "^--$" | \
        sed -N 's/^[[:space:]]*##[[:space:]]*//p; n; s/^[[:space:]]*alias \([^=]*\)=.*/\1/p; s/^[[:space:]]*function \([^ (]*\).*/\1/p' | \
        paste - - | \
        awk -F'\t' '{printf "  %-10s : %s\n", $2, $1}')

    echo "🔥 Available Actions:"
    echo "$menu_items"
    
    echo ""
    gum style --foreground 244 -- "=== Shortcuts ==="
    echo "  del <file> : Move to Trash (Safe Delete)"
    echo "  Ctrl+R     : Search History (Atuin)"
    echo "  Tab        : Visual Completion (FZF)"
}

# --- 4. Definitions with Docs (For Guide) ---

## Dashboard (Start here)
alias d="dev"

## Launch Work Environment
alias w="work"

## Create New Project
alias m="mkproj"

## Finish & Save Work
alias f="finish-work"

## Smart Editor (Code/Nvim)
alias e="edit"

## Ask AI (Gemini)
alias a="ask"

## Git Cockpit (Lazygit)
alias g="lazygit"

## Workspace (Zellij)
alias zj="zellij"

## Safe Delete (Trash)
alias del="trash-put"

## Reload Shell
alias sz="exec zsh"

# --- 5. Loader (Secrets & Functions) ---
[ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"

if [ -d "$DOTFILES/zsh/functions" ]; then
  for f in "$DOTFILES/zsh/functions/"*.zsh; do
    [ -r "$f" ] && source "$f"
  done
fi

# --- 6. Tool Init (Hooks) ---
# Starship / Direnv は Nix側でも設定されているが、
# Live-Link での確実な読み込みのためにフックを確認
command -v starship >/dev/null && eval "$(starship init zsh)"
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
