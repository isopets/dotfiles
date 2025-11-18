#!/bin/bash
# Dotfiles Link Script (Final Version)

DOT_DIR="$HOME/dotfiles"
echo "🚀 Dotfilesのリンク作成を開始します..."

link_file() {
    local source="$DOT_DIR/$1"
    local target="$HOME/$2"

    if [ ! -e "$source" ]; then
        echo "☁️  Missing: $source"
        return
    fi
    mkdir -p "$(dirname "$target")"
    if [ -e "$target" ]; then
        echo "👌 Skip: Already exists: $target"
    else
        ln -sv "$source" "$target"
        echo "✅ Linked: $target"
    fi
}

echo -e "\n--- Zsh ---"
link_file "zsh/.zshrc" ".zshrc"
link_file "zsh/.zprofile" ".zprofile" # 必要なら

echo -e "\n--- Git ---"
link_file "git/.gitconfig" ".gitconfig"
link_file "git/.gitignore_global" ".gitignore_global"

echo -e "\n--- Warp & Tmux ---"
link_file "warp/.warp" ".warp"
link_file "tmux/.tmux.conf" ".tmux.conf"

echo -e "\n--- VS Code Profiles ---"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
DOT_VSCODE_PROFILES="$DOT_DIR/vscode/profiles"

if [ -d "$VSCODE_USER_DIR" ] && [ -d "$DOT_VSCODE_PROFILES" ]; then
    # 基本設定
    link_file "vscode/keybindings.json" "Library/Application Support/Code/User/keybindings.json"
    link_file "vscode/snippets" "Library/Application Support/Code/User/snippets"
    
    # プロファイルの動的リンク
    for profile_path in "$DOT_VSCODE_PROFILES"/*; do
        if [ -d "$profile_path" ]; then
            profile_name=$(basename "$profile_path")
            target_dir="$VSCODE_USER_DIR/profiles/$profile_name"
            mkdir -p "$target_dir"
            echo "   🔗 Linking Profile: $profile_name"
            ln -sfv "$profile_path/settings.json" "$target_dir/settings.json"
        fi
    done
else
    echo "👀 VS Code directories not found."
fi

echo -e "\n🎉 All done! Everything is safe."
