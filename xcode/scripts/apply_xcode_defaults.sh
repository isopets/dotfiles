#!/bin/bash

echo "🛠️ Applying Xcode preferences..."

# 1. 行番号を表示
defaults write com.apple.dt.Xcode DVTTextShowLineNumbers -bool true

# 2. コードの折りたたみを有効化
defaults write com.apple.dt.Xcode DVTTextShowCodeFoldingSidebar -bool true

# 3. ビルド時間を表示 (上級者向け)
defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool true

# 4. インデックス作成を並列化 (高速化)
defaults write com.apple.dt.Xcode IDEIndexEnableDataStore -bool true

# 5. 空白のトリミング (保存時)
defaults write com.apple.dt.Xcode DVTTextEditorTrimTrailingWhitespace -bool true
defaults write com.apple.dt.Xcode DVTTextEditorTrimWhitespaceOnlyLines -bool true

# 6. スペース4つ (インデント)
defaults write com.apple.dt.Xcode DVTTextIndentTabWidth -int 4
defaults write com.apple.dt.Xcode DVTTextIndentWidth -int 4
defaults write com.apple.dt.Xcode DVTTextIndentUseTabs -bool false

echo "✅ Xcode defaults applied. Please restart Xcode."
