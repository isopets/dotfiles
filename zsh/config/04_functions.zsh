# =================================================================
# 🛠️ Helper Functions
# =================================================================

# --- 定数設定 (自分の環境に合わせて変更可能) ---
export REAL_CODE_DIR="$HOME/Projects"     # コードの実体
export REAL_ASSETS_DIR="$HOME/Creative"   # 素材の実体
export PARA_DIR="$HOME/PARA"              # 作業用仮想フォルダ

# ---------------------------------------------------
# 1. Bitwarden Integration (パスワード連携)
# ---------------------------------------------------

# 使い方: bwenv <アイテム名> <環境変数名>
# 例: bwenv "AWS_Account" "AWS_ACCESS_KEY"
function bwenv() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "❌ Usage: bwenv <Item Name> <ENV_VAR_NAME>"
        return 1
    fi
    echo "🔍 Fetching password for '$1'..."
    
    # Bitwardenからパスワード取得
    local pass=$(bw get password "$1")
    
    if [ -z "$pass" ]; then
        echo "❌ Error: Item not found or locked."
        return 1
    fi
    
    # .env に追記
    echo "$2=$pass" >> .env
    echo "✅ Added '$2' to .env!"
}

# 使い方: bwfzf <環境変数名> (検索して選択)
function bwfzf() {
    if [ -z "$1" ]; then
        echo "❌ Usage: bwfzf <ENV_VAR_NAME>"
        return 1
    fi
    echo "⏳ Loading Bitwarden items..."
    
    # fzfで選択
    local item_name=$(bw list items --search "" | jq -r '.[].name' | fzf --prompt="Select Item > ")
    
    if [ -z "$item_name" ]; then
        echo "🚫 Canceled."
        return 1
    fi
    
    bwenv "$item_name" "$1"
}


# ---------------------------------------------------
# 2. Project Management (仮想PARA & コックピット)
# ---------------------------------------------------

# プロジェクト作成 (コード・素材・Direnv・ポータルを一括作成)
# Usage: mkproj <Category> <ProjectName>
# Example: mkproj Personal My-Blog
function mkproj() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "❌ Usage: mkproj <Category> <ProjectName>"
        return 1
    fi

    local category="$1"
    local name="$2"
    
    # パス定義
    local code_dir="$REAL_CODE_DIR/$category/$name"
    local creative_dir="$REAL_ASSETS_DIR/$category/$name"
    local para_path="$PARA_DIR/1_Projects/$name"

    # 1. フォルダ作成
    mkdir -p "$code_dir/.vscode"
    mkdir -p "$creative_dir"/{Design,Video,Export,Docs}
    mkdir -p "$para_path"

    # 2. ポータル（相互リンク）の作成
    # コードフォルダ内に素材へのリンク
    ln -s "$creative_dir" "$code_dir/_GoToCreative"
    # 素材フォルダ内にコードへのリンク
    ln -s "$code_dir" "$creative_dir/_GoToCode"

    # 3. PARA（仮想フォルダ）へのリンク作成
    ln -s "$code_dir" "$para_path/💻_Code"
    ln -s "$creative_dir" "$para_path/🎨_Assets"

    # 4. direnv & .env 設定 (自動化)
    # .env作成
    touch "$code_dir/.env"
    # .envrc作成 (dotenvを読み込む設定)
    echo "dotenv" > "$code_dir/.envrc"
    
    # .gitignore に環境設定を追加
    echo ".env" >> "$code_dir/.gitignore"
    echo ".envrc" >> "$code_dir/.gitignore"

    echo "✨ Project & Portals Created!"
    echo "📂 Code:     $code_dir"
    echo "🎨 Creative: $creative_dir"
    echo "📍 PARA:     $para_path"

    # 作成した場所へ移動して direnv を許可
    cd "$code_dir"
    if command -v direnv &> /dev/null; then
        direnv allow .
    fi
}

# コックピット起動 (開発環境の一斉展開)
# Usage: work (選択) or work <ProjectName>
function work() {
    local project_name="$1"

    # 引数がなければ fzf で進行中のプロジェクト(1_Projects)から選択
    if [ -z "$1" ]; then
        project_name=$(ls "$PARA_DIR/1_Projects" | fzf --prompt="🚀 Launch Project > ")
        if [ -z "$project_name" ]; then echo "🚫 Canceled."; return 1; fi
    fi

    local project_path="$PARA_DIR/1_Projects/$project_name"

    if [ ! -d "$project_path" ]; then
        echo "❌ Project not found in PARA: $project_name"
        return 1
    fi

    echo "🚀 Launching Cockpit for: $project_name"

    # 1. VS Code でコードの実体を開く
    if [ -L "$project_path/💻_Code" ]; then
        local real_code_path=$(readlink "$project_path/💻_Code")
        code "$real_code_path"
        
        # ターミナルもその場所に移動
        cd "$real_code_path"
    fi

    # 2. Finder で素材フォルダを開く
    if [ -L "$project_path/🎨_Assets" ]; then
        open "$project_path/🎨_Assets"
    fi

    echo "✅ Environment is ready."
}

# ジャンプ (Projects <-> Creative の行き来)
function jump() {
    local current_dir=$(pwd)
    local target_dir=""

    if [[ "$current_dir" == *"/Projects/"* ]]; then
        target_dir="${current_dir/Projects/Creative}"
    elif [[ "$current_dir" == *"/Creative/"* ]]; then
        target_dir="${current_dir/Creative/Projects}"
    else
        echo "❌ Not in a Project or Creative folder."
        return 1
    fi

    if [ -d "$target_dir" ]; then
        cd "$target_dir"
        echo "🚀 Jumped to: $target_dir"
        eza --icons
    else
        echo "⚠️  Target directory does not exist."
    fi
}


# ---------------------------------------------------
# 3. VS Code Profile Management (CLI管理)
# ---------------------------------------------------

# プロファイル作成コマンド
# Usage: mkprofile "[Lang] Go" go.json
function mkprofile() {
    local name="$1"
    local file="$2"
    local vscode_dir="$HOME/dotfiles/vscode"
    local source_file="$vscode_dir/source/$file"

    if [ -z "$name" ] || [ -z "$file" ]; then
        echo "❌ Usage: mkprofile \"[Lang] Name\" filename.json"
        return 1
    fi

    # 1. 差分JSONがなければ作成
    if [ ! -f "$source_file" ]; then
        echo '{ "workbench.colorCustomizations": { "activityBar.background": "#333" } }' > "$source_file"
        # 編集のために開く
        code "$source_file"
    fi

    # 2. リストに追記 (重複チェック)
    if ! grep -q "$name" "$vscode_dir/profile_list.txt"; then
        echo "$name:$file" >> "$vscode_dir/profile_list.txt"
        echo "📝 Added to profile list."
    fi

    # 3. ビルドとリンク実行
    "$vscode_dir/update_settings.sh"
    "$HOME/dotfiles/setup.sh"

    echo "✨ Profile '$name' created and linked!"
}

# プロファイル削除コマンド
# Usage: rmprofile "[Lang] Python"
function rmprofile() {
    local name="$1"
    local vscode_dir="$HOME/dotfiles/vscode"
    local list_file="$vscode_dir/profile_list.txt"

    if [ -z "$name" ]; then
        echo "❌ Usage: rmprofile \"[Profile Name]\""
        return 1
    fi

    # リストから検索
    local line_to_delete=$(grep "$name" "$list_file")
    if [ -z "$line_to_delete" ]; then
        echo "🤔 Profile not found in list."
        return 1
    fi
    
    local json_file=$(echo "$line_to_delete" | awk -F: '{print $2}')
    local source_json="$vscode_dir/source/$json_file"

    echo "🚨 Delete profile '$name' and source '$json_file'? (yes/no)"
    read -r confirm
    if [ "$confirm" != "yes" ]; then echo "🚫 Canceled."; return 1; fi

    # 削除処理 (gsed使用)
    gsed -i "/$name/d" "$list_file"
    
    if [ -f "$source_json" ]; then
        rm "$source_json"
        echo "🗑️  Source JSON deleted."
    fi
    
    # 再ビルドとリンク
    "$vscode_dir/update_settings.sh"
    "$HOME/dotfiles/setup.sh"
    
    # VS Code側のフォルダも削除
    rm -rf "$HOME/Library/Application Support/Code/User/profiles/$name"
    
    echo "✨ Profile '$name' deleted completely."
}


# ---------------------------------------------------
# 4. Utilities (便利機能)
# ---------------------------------------------------

# エイリアス検索 (ali)
function ali() {
    local selected_alias
    selected_alias=$(alias | fzf --prompt="Select Alias > " | cut -d'=' -f1)
    if [ -n "$selected_alias" ]; then
        print -z "$selected_alias"
    fi
}

# 設定一覧表示 (myhelp)
function myhelp() {
    # configフォルダの中身をまとめて表示
    cat ~/dotfiles/zsh/config/*.zsh | bat -l bash --style=plain
}
