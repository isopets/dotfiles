#!/bin/bash

XCODE_USER_DIR="$HOME/Library/Developer/Xcode/UserData"
REPO_DIR="$HOME/dotfiles/xcode/UserData"

echo "📥 Importing current Xcode configs to Dotfiles..."

# テーマ
echo "🎨 Importing Themes..."
cp -r "$XCODE_USER_DIR/FontAndColorThemes/"* "$REPO_DIR/FontAndColorThemes/" 2>/dev/null

# キーバインド
echo "⌨️ Importing KeyBindings..."
cp -r "$XCODE_USER_DIR/KeyBindings/"* "$REPO_DIR/KeyBindings/" 2>/dev/null

# スニペット
echo "🧩 Importing Snippets..."
cp -r "$XCODE_USER_DIR/CodeSnippets/"* "$REPO_DIR/CodeSnippets/" 2>/dev/null

echo "✅ Import complete! Run 'nix-up' to link them back."
