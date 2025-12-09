# =================================================================
# 🎮 Cockpit Core (Smart Editor Edition)
# =================================================================

export DOTFILES="$HOME/dotfiles"
export PATH="$HOME/.nix-profile/bin:$PATH"
setopt +o nomatch
setopt interactivecomments

# --- Aliases ---
alias rm="rm -i"
alias undo="trash-restore"
alias restore="trash-restore"
alias d="c"
# codeコマンド自体をCockpitのedit関数に置き換える（VS Codeのパスを通した上で）
alias code="edit"
alias e="edit"

# --- 📝 Smart Editor (Context Aware) ---
function edit() {
    local target="${1:-.}"
    
    # 1. 指定されたパスがGit管理下かチェック
    # (親ディレクトリを遡って .git を探す)
    local git_root=""
    if [ -f "$target" ] || [ -d "$target" ]; then
        # 絶対パス等に対応するため、その場へ行ってから調査
        local target_dir=$(dirname "$target")
        git_root=$(git -C "$target_dir" rev-parse --show-toplevel 2>/dev/null)
    fi

    # 2. エディタの起動分岐
    if [ -n "$git_root" ]; then
        # Git管理下なら: 「プロジェクトルート」と「対象ファイル」の両方を渡す
        # これにより、VS Codeはプロジェクト全体を開きつつ、ファイルを表示する
        echo "🚀 Opening Project: $(basename "$git_root")"
        if command -v code >/dev/null; then
            command code "$git_root" "$target"
        else
            nvim "$target" # Fallback
        fi
    else
        # Git管理外なら: そのまま開く
        if command -v code >/dev/null; then
            command code "$target"
        else
            nvim "$target"
        fi
    fi
}

# --- 🗑️ Cockpit Visual Delete (維持) ---
function del() {
    local base_fd="fd --type f --hidden --follow --exclude .git"
    local current_cmd="$base_fd --max-depth 1 ."
    local prompt_str="📂 Current > " 

    if [ $# -gt 0 ]; then
        if [[ "$1" == "-r" ]]; then _run_del_loop "$base_fd ." "🌍 Recursive > ";
        elif [[ "$1" == "." ]]; then _run_del_loop "$base_fd --max-depth 1 ." "📂 Current > ";
        else _run_del_loop "printf '%s\n' $@" "🎯 Target > "; fi
        return
    fi

    while true; do
        local result=$(eval "$current_cmd" | fzf -m --height 80% --layout=reverse --border \
            --prompt="$prompt_str" \
            --header="Enter:🗑️ Delete / Tab:✅ Select / Ctrl-O:⚙️ Menu" \
            --preview 'if [[ $(file --mime {}) =~ image ]]; then chafa -c full --size=40x20 {}; elif [ -d {} ]; then eza --tree --level=2 --icons {}; else bat --style=numbers --color=always --line-range :50 {}; fi' \
            --preview-window=right:50% \
            --bind "ctrl-a:select-all,ctrl-d:deselect-all" \
            --bind "ctrl-o:become(echo ___MENU___)" \
            --expect=ctrl-o)

        local selection=$(echo "$result" | tail -n +2)

        if [[ "$selection" == "___MENU___" ]]; then
            local volumes=$(ls -d /Volumes/* 2>/dev/null | grep -v "Macintosh HD" | xargs -I {} basename "{}")
            local vol_menu=""
            [ -n "$volumes" ] && while read -r vol; do vol_menu+="💾 Volume: $vol"$'\n'; done <<< "$volumes"
            
            local target_label=$(gum choose --header="📍 Change Location" --limit=1 \
                "📂 Current Directory" "🚀 Project Root" "⬇️  Downloads" "🖥️  Desktop" "🏠 Home" "$vol_menu" "❌ Cancel")
            
            local target_path="."
            case "$target_label" in
                *"Current"*) target_path="." ;;
                *"Project"*) target_path=$(git rev-parse --show-toplevel 2>/dev/null || echo ".") ;;
                *"Downloads"*) target_path="$HOME/Downloads" ;;
                *"Desktop"*) target_path="$HOME/Desktop" ;;
                *"Home"*) target_path="$HOME" ;;
                *"Volume:"*) target_path="/Volumes/$(echo "$target_label" | sed 's/💾 Volume: //')" ;;
                *"Cancel"*) continue ;;
            esac

            local filter_opts="--max-depth 1"
            local type_label=$(gum choose --header="🔍 Filter Type" --limit=1 \
                "🌈 All Files" "🌍 Recursive" "🖼️  Images" "🎥 Videos" "📄 Documents" "🐘 Huge (>100M)" "📅 Old (>30d)")
            
            case "$type_label" in
                *"Recursive"*) filter_opts=""; prompt_str="🌍 $target_label > " ;;
                *"Images"*) filter_opts="-e png -e jpg -e jpeg -e webp -e heic"; prompt_str="🖼️  Images > " ;;
                *"Videos"*) filter_opts="-e mp4 -e mov -e mkv -e avi"; prompt_str="🎥 Videos > " ;;
                *"Documents"*) filter_opts="-e pdf -e doc -e docx -e xls -e ppt -e md -e txt"; prompt_str="📄 Docs > " ;;
                *"Huge"*) filter_opts="--size +100M"; prompt_str="🐘 Huge > " ;;
                *"Old"*) filter_opts="--change-older-than 30days"; prompt_str="📅 Old > " ;;
                *) prompt_str="📂 $target_label > " ;;
            esac
            current_cmd="$base_fd $filter_opts . \"$target_path\""
            continue
        elif [[ -n "$selection" ]]; then
            echo "$selection" | tr '\n' '\0' | xargs -0 -r trash-put
            [ $? -eq 0 ] && echo ""
            break
        else
            break
        fi
    done
}

function _run_del_loop() {
    eval "$1" | fzf -m --height 80% --layout=reverse --border --prompt="$2" \
        --header="Enter:🗑️ Delete / Tab:✅ Select" \
        --preview 'if [[ $(file --mime {}) =~ image ]]; then chafa -c full --size=40x20 {}; elif [ -d {} ]; then eza --tree --level=2 --icons {}; else bat --style=numbers --color=always --line-range :50 {}; fi' \
        --preview-window=right:50% \
        --bind "ctrl-a:select-all,ctrl-d:deselect-all" \
    | tr '\n' '\0' | xargs -0 -r trash-put
    [ $? -eq 0 ] && echo ""
}

# --- ♻️ Super Reload ---
function sz() {
    echo "🧹 Resetting shell..."
    tput reset 2>/dev/null || clear
    exec zsh
}

# --- 🔓 Allow App ---
function allow() {
    local app_name="$1"
    if [ -z "$app_name" ]; then
        app_name=$(ls /Applications | grep ".app$" | sed 's/.app//' | fzf --prompt="Unlock > " --height=40% --layout=reverse)
        [ -z "$app_name" ] && return
    fi
    local app_path="/Applications/${app_name}.app"
    [ ! -d "$app_path" ] && echo "❌ '$app_name' not found." && return 1
    echo "🔓 Unlocking $app_name..."
    sudo xattr -d com.apple.quarantine "$app_path" 2>/dev/null
    echo "✅ Allowed."
}

# --- 🎮 Dashboard (dev) ---
function dev() {
    local mode="GLOBAL"; local color="39"
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 && mode="PROJECT" && color="214"
    echo ""; gum style --foreground "$color" --bold --border double --padding "0 2" "🧭 COCKPIT COMMANDER"
    local selected=""
    
    if [ "$mode" = "PROJECT" ]; then
        selected=$(gum choose --cursor="👉 " --selected.foreground="$color" \
            "🚀 Work      : 仕事を始める" \
            "🏁 Finish    : 終了・日報作成 (Daily)" \
            "💬 Commit    : AIコミット" \
            "🤖 Ask AI    : 質問" \
            "🕹️  Git       : Git操作" \
            "🔙 Exit      : 戻る")
    else
        selected=$(gum choose --cursor="👉 " --selected.foreground="$color" \
            "📂 Jump      : プロジェクトを開く" \
            "✨ New       : 新規プロジェクト (Template)" \
            "🤖 Ask AI    : 質問" \
            "🛠️  Update    : システム更新" \
            "📦 Install   : アプリ追加" \
            "🏥 Check     : 診断" \
            "🧹 Clean     : 掃除" \
            "🔑 Save Key  : パスワード")
    fi

    case "$selected" in
        *"Work"*) work ;; *"Finish"*) daily ;; *"Commit"*) gcm ;;
        *"Ask AI"*) echo -n "🤖 Q: "; read q; ask "$q" ;; *"Git"*) lazygit ;;
        *"Exit"*) cd ~; dev ;; *"Jump"*) p ;; *"New"*) mkproj ;;
        *"Update"*) nix-up ;; *"Install"*) nix-add ;; *"Check"*) audit ;;
        *"Clean"*) cleanup ;; *"Save Key"*) save-key ;;
    esac
}

# --- 🕹️ Omni Command (c) ---
function c() {
    [ $# -eq 0 ] && dev && return
    local subcmd="$1"; shift
    case "$subcmd" in
        "w"|"work") work "$@" ;; "n"|"new") mkproj "$@" ;; "f"|"fin"|"done") daily ;;
        "go"|"p") p ;; "e"|"edit") edit "$@" ;; "ai"|"ask") ask "$@" ;;
        "g"|"git") lazygit ;; "z"|"zj") zellij ;; "up") nix-up ;;
        "fix") sz ;; "del") del "$@" ;; "undo") undo ;; "allow") allow "$@" ;;
        *) echo "❌ Unknown: c $subcmd" ;;
    esac
}

## ❓ Interactive Help & Launcher
function cockpit-help() {
    echo "🤔 What do you want to do?"
    
    # コマンド定義: "説明文 | 実行コマンド"
    local selected=$(gum choose --header="🚀 Cockpit Actions" --height=20 \
        "✨ New Project        (m)    | mkproj" \
        "🚀 Start Work         (w)    | work" \
        "📝 Daily Report       (done) | daily" \
        "🔄 Sync Settings      (sync) | sync-config" \
        "🛠️ Edit Config        (conf) | code-config" \
        "📦 Install App        (app)  | app" \
        "📥 Import VSCode      (migrate)| import-vscode" \
        "📤 Eject Cockpit      (eject)| eject-cockpit" \
        "🏥 Health Check       (check)| audit" \
        "🧹 Clean Garbage      (del)  | del" \
        "🤖 Ask AI             (ask)  | ask" \
        "⬆️  Update System      (up)   | nix-up")

    # 選ばれなかったら終了
    [ -z "$selected" ] && return

    # "|" で区切って右側のコマンドを取り出す
    local cmd=$(echo "$selected" | awk -F '|' '{print $2}' | xargs)
    
    echo "Executing: $cmd ..."
    eval "$cmd"
}

alias \?="cockpit-help"

## 💾 Save Cockpit (Git Push Dotfiles)
function save-cockpit() {
    local dir="$HOME/dotfiles"
    
    # 変更があるか確認
    if [ -z "$(git -C "$dir" status --porcelain)" ]; then
        echo "✅ Cockpit is already up to date. (No changes)"
        return
    fi
    
    echo "💾 Saving Cockpit state to Cloud..."
    
    # 変更内容を表示
    git -C "$dir" status -s
    
    # コミットメッセージ入力（空なら日時）
    echo -n "💬 Message (Enter for auto): "
    read msg
    [ -z "$msg" ] && msg="save: $(date '+%Y-%m-%d %H:%M')"
    
    # Push処理
    git -C "$dir" add .
    git -C "$dir" commit -m "$msg"
    
    if git -C "$dir" push; then
        echo "☁️  Cockpit settings synced to GitHub!"
    else
        echo "❌ Failed to push. Check internet or git config."
    fi
}

alias save="save-cockpit"
