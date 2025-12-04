#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Generate API Key Name
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🏷️
# @raycast.packageName Cockpit Utils

# Documentation:
# @raycast.description Generate naming convention string and paste it.

# 1. 名前の生成ロジック (Zshと同じロジック)
HOST=$(scutil --get LocalHostName | sed 's/isogaiyuujinno//' | sed 's/isogaiyuto//')
DATE=$(date +%Y%m)
NAME="Cockpit-${HOST}-${DATE}"

# 2. クリップボードにコピー
echo -n "$NAME" | pbcopy

# 3. 現在のアプリにペースト (AppleScript)
osascript -e 'tell application "System Events" to keystroke "v" using command down'

# 4. 通知 (音だけ、あるいは控えめに)
# echo "Pasted: $NAME" # silentモードなので表示されないがログには残る
