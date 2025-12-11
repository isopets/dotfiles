#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Create New Project
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🏗️
# @raycast.packageName Cockpit
# @raycast.argument1 { "type": "text", "placeholder": "Project Name (Optional)" }

# Documentation:
# @raycast.description Opens Terminal to run mkproj wizard

PROJECT_NAME="$1"

# ターミナル(Alacritty)を開いて mkproj を実行させる
# 引数があればそれを渡す、なければウィザードモード
if [ -n "$PROJECT_NAME" ]; then
    CMD="mkproj $PROJECT_NAME"
else
    CMD="mkproj"
fi

osascript -e "tell application \"Alacritty\"
    activate
    do script \"exec zsh -c 'source ~/.zshrc; $CMD'\"
end tell"
