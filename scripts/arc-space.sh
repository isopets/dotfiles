#!/bin/bash
# Arc Browser Space Switcher
SPACE_NUM="$1"
[ -z "$SPACE_NUM" ] && SPACE_NUM=1

# Arcに Ctrl + 数字キー を送信してスペース切り替え
osascript -e "tell application \"System Events\" to tell process \"Arc\"
    keystroke \"$SPACE_NUM\" using {control down}
end tell"
