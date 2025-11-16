#!/bin/bash

# ----------------------------------------------------------
# Dotfiles Link Script (Clear & Safe Edition)
# 実行方法: ./setup.sh
# ----------------------------------------------------------

# このスクリプトがある場所を基準にする
DOT_DIR="$HOME/dotfiles"

echo "🚀 Dotfilesのリンク作成を開始します..."

# ----------------------------------------------------------
# 1. 関数定義: 安全にシンボリックリンクを貼る関数
# usage: link_file "dotfiles内のパス" "ホームディレクトリのパス"
# ----------------------------------------------------------
link_file() {
    local source="$DOT_DIR/$1"
    local target="$HOME/$2"

    # リンク元のファイルが存在しない場合はメッセージを出してスキップ
    if [ ! -e "$source" ]; then
        # ☁️ = 元ファイルがない（まだ作っていない場合など）
        echo "☁️  Missing: $source"
        return
    fi

    # 親フォルダがない場合は作成する（例: ~/.configなど）
    mkdir -p "$(dirname "$target")"

    # 【重要】ターゲットが既に存在するかチェック
    if [ -e "$target" ]; then
        # 既に存在する場合は何もしない
        # 👌 = 既にファイルがあるからOK（現状維持）
        echo "👌 Skip: Already exists: $target"
    else
        # 存在しない場合のみリンクを作成
        # ✅ = リンク作成成功（分かりやすいチェックマーク）
        ln -sv "$source" "$target"
        echo "✅ Linked: $target"
    fi
}

# ----------------------------------------------------------
# 2. Zsh (シェル)
# ----------------------------------------------------------
echo -e "\n--- Zsh ---"
link_file "zsh/.zshrc" ".zshrc"
link_file "zsh/.zprofile" ".zprofile"

# ----------------------------------------------------------
# 3. Git
# ----------------------------------------------------------
echo -e "\n--- Git ---"
link_file "git/.gitconfig" ".gitconfig"
link_file "git/.gitignore_global" ".gitignore_global"

# ----------------------------------------------------------
# 4. Warp (ターミナル)
# ----------------------------------------------------------
echo -e "\n--- Warp ---"
# Warpはフォルダごとリンクする
link_file "warp/.warp" ".warp"

# ----------------------------------------------------------
# 5. VS Code (macOS用パス)
# ----------------------------------------------------------
echo -e "\n--- VS Code ---"

# macOSのVSCode設定パス
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

if [ -d "$VSCODE_USER_DIR" ]; then
    # settings.json
    link_file "vscode/settings.json" "Library/Application Support/Code/User/settings.json"
    
    # keybindings.json
    link_file "vscode/keybindings.json" "Library/Application Support/Code/User/keybindings.json"
    
    # snippetsフォルダ (フォルダごとリンク)
    link_file "vscode/snippets" "Library/Application Support/Code/User/snippets"
else
    echo "👀 VS Code directory not found. Skipping..."
fi

# ----------------------------------------------------------
# 完了
# ----------------------------------------------------------
echo -e "\n🎉 All done! Everything is safe."