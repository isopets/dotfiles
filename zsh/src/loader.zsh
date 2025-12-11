# 🚀 Cockpit Module Loader
# modulesフォルダ内の全ての .zsh ファイルを番号順に読み込む

MODULE_DIR="$HOME/dotfiles/zsh/src/modules"

if [ -d "$MODULE_DIR" ]; then
    for file in "$MODULE_DIR"/*.zsh(N); do
        source "$file"
    done
fi
