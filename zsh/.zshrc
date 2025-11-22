ZSH_CONFIG_DIR="$HOME/dotfiles/zsh/config"
# API Key (Bitwardenからロードまたは手動設定)
if [ -f "$HOME/dotfiles/zsh/.zsh_secrets" ]; then source "$HOME/dotfiles/zsh/.zsh_secrets"; fi

# 自動同期
VSCODE_SYNC="$HOME/dotfiles/vscode/sync_extensions.sh"; LAST="$HOME/.vscode_last_sync"
if [ -f "$LAST" ]; then
    if [ $(( $(date +%s) - $(cat "$LAST") )) -gt 86400 ]; then nohup "$VSCODE_SYNC" >/dev/null 2>&1 &!; date +%s > "$LAST"; fi
else nohup "$VSCODE_SYNC" >/dev/null 2>&1 &!; date +%s > "$LAST"; fi

if [ -d "$ZSH_CONFIG_DIR" ]; then for f in "$ZSH_CONFIG_DIR"/*.zsh; do source "$f"; done; fi
if [[ $(git -C "$HOME/dotfiles" status --porcelain) ]]; then echo "🚨 Dotfiles Uncommitted Changes!"; fi
[ -x "$HOME/dotfiles/scripts/check_unmanaged_profiles.sh" ] && "$HOME/dotfiles/scripts/check_unmanaged_profiles.sh"
