# =================================================================
# 🛠️ 05_tools.zsh : Visuals & Power Tools (Fixed FZF)
# =================================================================

# --- 1. Modern Navigation (Zoxide) ---
if command -v zoxide >/dev/null; then
    eval "$(zoxide init zsh)"
    alias cd="z"
fi

# --- 2. Rich Visuals (Eza & Bat) ---
if command -v eza >/dev/null; then
    alias ls="eza --icons --git --group-directories-first"
    alias ll="eza --icons --git -l --group-directories-first"
    alias la="eza --icons --git -la --group-directories-first"
    alias tree="eza --tree --level=2 --icons"
fi

if command -v bat >/dev/null; then
    alias cat="bat"
    export BAT_THEME="Dracula"
fi

# --- 3. FZF (The Fuzzy Finder) Integration ---
if command -v fzf >/dev/null; then
    # デザイン設定
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info --prompt="🔍 " --pointer="▶" --marker="✓"'
    export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"
    
    # 【重要】キーバインドの強制読み込み
    # 1. 新しいバージョン (fzf --zsh)
    if fzf --zsh >/dev/null 2>&1; then
        eval "$(fzf --zsh)"
    else
        # 2. Nix / Homebrew のパスを総当たりで探して読み込む
        local fzf_paths=(
            "/usr/share/fzf/key-bindings.zsh"
            "/usr/share/doc/fzf/examples/key-bindings.zsh"
            "$HOME/.nix-profile/share/fzf/key-bindings.zsh"
            "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
            "/usr/local/opt/fzf/shell/key-bindings.zsh"
            "$HOME/.fzf.zsh"
        )
        for p in $fzf_paths; do
            if [ -f "$p" ]; then
                source "$p"
                break
            fi
        done
    fi
fi

# --- 4. Browser Profiles ---
alias chrome-work='open -n -a "Google Chrome" --args --user-data-dir="$HOME/dotfiles/chrome/profiles/work"'
alias chrome-personal='open -n -a "Google Chrome" --args --user-data-dir="$HOME/dotfiles/chrome/profiles/personal"'

# --- 5. System Utils ---
alias ip="curl ifconfig.me"
alias port="lsof -i -P"
alias disk="du -h -d 1"
