#!/bin/bash
# 🚀 Cockpit Startup Launcher

export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

MODE=$(gum choose --header="🚀 Good Morning! Select Mission Mode:" \
    "💻 Dev Mode (Code, Slack, Browser)" \
    "📝 Write Mode (Notion, Music, Browser)" \
    "☕ Casual Mode (Discord, Music, Browser)" \
    "🌑 Silent Mode (Browser Only)")

echo "🚀 Initiating $MODE..."

# 共通: 既定のブラウザで空白ページを開く (Arc/Chrome/Safari対応)
open "about:blank"
sleep 1

case "$MODE" in
    *"Dev Mode"*)
        open -a "Visual Studio Code"
        open -a "Alacritty"
        open -a "Slack"
        # Arcを使っている場合のみスペース切替を試みる
        if pgrep -x "Arc" >/dev/null; then ~/dotfiles/scripts/arc-space.sh 1; fi
        ;;
        
    *"Write Mode"*)
        open -a "Notion"
        open -a "Spotify"
        if pgrep -x "Arc" >/dev/null; then ~/dotfiles/scripts/arc-space.sh 2; fi
        ;;
        
    *"Casual Mode"*)
        open -a "Discord"
        open -a "Spotify"
        if pgrep -x "Arc" >/dev/null; then ~/dotfiles/scripts/arc-space.sh 3; fi
        ;;
esac

osascript -e 'display notification "Systems Nominal. Engage." with title "Cockpit"'
