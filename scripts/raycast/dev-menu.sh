#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Cockpit Dashboard
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🚀
# @raycast.packageName Cockpit

# Documentation:
# @raycast.description Open Cockpit Dashboard via Alacritty/Terminal

# あなたが使っているターミナルアプリ名に合わせて変更してください
# 例: "Alacritty", "iTerm", "Terminal"
TERM_APP="Alacritty"

# AppleScriptを使ってターミナルを起動し、devコマンドを送り込む
osascript -e "tell application \"$TERM_APP\"
    activate
    do script \"exec zsh -c 'source ~/.zshrc; dev'\"
end tell"