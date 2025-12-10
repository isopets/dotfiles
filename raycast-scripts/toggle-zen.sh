#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Zen Mode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🧘
# @raycast.packageName Cockpit

# Documentation:
# @raycast.description Toggle Dock & Borders for Zen Mode
# @raycast.author You

# パスを通す
export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Dockの状態を確認 (autohideがtrueならZen中)
IS_ZEN=$(osascript -e 'tell application "System Events" to get autohide of dock preferences')

if [ "$IS_ZEN" == "false" ]; then
    # --- 🧘 ZEN MODE ON ---
    
    # 1. Dockを隠す
    osascript -e 'tell application "System Events" to set the autohide of the dock preferences to true'
    
    # 2. 枠線を消す (JankyBorders)
    borders width=0.0 active_color=0x00000000 inactive_color=0x00000000
    
    # 3. 通知
    echo "🧘 Zen Mode: ON"
    echo "(Tip: Press 'Alt+;' then 'g' to remove gaps)"

else
    # --- 🌅 NORMAL MODE ---
    
    # 1. Dockを出す
    osascript -e 'tell application "System Events" to set the autohide of the dock preferences to false'
    
    # 2. 枠線を戻す (元の設定: width=6.0, 紫色)
    borders width=6.0 active_color=0xff7c4dff inactive_color=0x00000000
    
    # 3. 通知
    echo "🌅 Zen Mode: OFF"
    echo "(Tip: Press 'Alt+;' then 'Shift+g' to restore gaps)"
fi
