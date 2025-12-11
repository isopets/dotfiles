# =================================================================
# ⚡ Cockpit Aliases (Shortcuts & Keybindings)
# =================================================================

# --- 1. System & Cockpit Control ---
alias sz="reload"          # 安全な設定再読み込み
alias up="nix-up"          # システム全体更新 (HUD)
alias undo="rollback"      # 失敗した時のタイムマシン (Nix世代戻し)
alias wtf="explain"        # コマンドの意味をAIに聞く
alias h="cd ~"             # ホームへ帰還

# --- 2. Project & Work ---
alias mk="mkproj"          # プロジェクト作成 (最短)
alias w="mkproj"           # 仕事開始 (Work)
alias start="run"          # 実行 (Justfile/Auto)
alias v="code"             # VS Codeを開く

# --- 3. Navigation (PARA) ---
alias d="cd ~/PARA/0_Inbox"      # Inbox (Dump)
alias p="cd ~/PARA/1_Projects"   # Projects
alias ..="cd .."
alias ...="cd ../.."

# --- 4. Modern Unix Tools (Better defaults) ---
# ls -> eza (アイコン付き、カラー表示) ※ezaがない場合は通常のls
if command -v eza >/dev/null; then
    alias ls="eza --icons --git"
    alias ll="eza --icons --git -l"
    alias la="eza --icons --git -la"
else
    alias ll="ls -l"
    alias la="ls -la"
fi

# cat -> bat (シンタックスハイライト付き) ※batがない場合は通常のcat
if command -v bat >/dev/null; then
    alias cat="bat"
fi

# --- 5. Git Operations ---
alias g="git"
alias lg="lazygit"         # TUIでGit操作
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"

# --- 6. Neuro / Context Switching ---
alias pl="play"            # 砂場 (実験環境)
alias pf="pastefile"       # クリップボードをファイル化
alias zone="flow"          # 集中モード (通知OFF)
alias bgm="ambience"       # 環境音再生
alias memo="code ~/PARA/0_Inbox/Memo_$(date +%Y-%m-%d).md"

# --- 7. Core Override ---
# VS Codeを呼び出すときは必ず Context-Aware Launcher (copen) を通す
alias code="copen"
alias dump-cockpit="~/dotfiles/scripts/dump_context.sh"
