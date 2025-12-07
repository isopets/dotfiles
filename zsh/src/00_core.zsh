# =================================================================
# 🎮 Cockpit Core (Icon Rich Edition)
# =================================================================

# --- System Context ---
export DOTFILES="$HOME/dotfiles"
export PATH="$HOME/.nix-profile/bin:$PATH"
setopt +o nomatch
setopt interactivecomments

# --- Safety & Aliases ---
alias rm="rm -i"
alias undo="trash-restore"
alias restore="trash-restore"
alias d="c"
alias e="edit"

# ---  Cockpit Visual Delete ---
function del() {
    local base_fd="fd --type f --hidden --follow --exclude .git"
    local current_cmd="$base_fd --max-depth 1 ."
    local prompt_str=" Current > " 

    # Direct Mode
    if [ $# -gt 0 ]; then
        if [[ "$1" == "-r" ]]; then _run_del_loop "$base_fd ." " Recursive > ";
        elif [[ "$1" == "." ]]; then _run_del_loop "$base_fd --max-depth 1 ." " Current > ";
        else _run_del_loop "printf '%s\n' $@" " Target > "; fi
        return
    fi

    # Main Loop
    while true; do
        # fzf実行: アイコン付きヘッダー
        local result=$(eval "$current_cmd" | fzf -m --height 80% --layout=reverse --border \
            --prompt="$prompt_str" \
            --header="Enter: Delete / Tab: Select / Ctrl-O: Menu" \
            --preview 'if [[ $(file --mime {}) =~ image ]]; then chafa -c full --size=40x20 {}; elif [ -d {} ]; then eza --tree --level=2 --icons {}; else bat --style=numbers --color=always --line-range :50 {}; fi' \
            --preview-window=right:50% \
            --bind "ctrl-a:select-all,ctrl-d:deselect-all" \
            --bind "ctrl-o:become(echo ___MENU___)" \
            --expect=ctrl-o)

        local selection=$(echo "$result" | tail -n +2)

        if [[ "$selection" == "___MENU___" ]]; then
            # ===  Menu Mode ===
            
            # Step 1: Scope
            local volumes=$(ls -d /Volumes/* 2>/dev/null | grep -v "Macintosh HD" | xargs -I {} basename "{}")
            local vol_menu=""
            [ -n "$volumes" ] && while read -r vol; do vol_menu+=" Volume: $vol"$'\n'; done <<< "$volumes"
            
            # アイコン復活！
            local target_label=$(gum choose --header=" Change Location" --limit=1 \
                " Current Directory" " Project Root" " Downloads" \
                " Desktop" " Home" "$vol_menu" " Cancel")
            
            local target_path="."
            case "$target_label" in
                *"Current"*) target_path="." ;;
                *"Project"*) target_path=$(git rev-parse --show-toplevel 2>/dev/null || echo ".") ;;
                *"Downloads"*) target_path="$HOME/Downloads" ;;
                *"Desktop"*) target_path="$HOME/Desktop" ;;
                *"Home"*) target_path="$HOME" ;;
                *"Volume:"*) target_path="/Volumes/$(echo "$target_label" | sed 's/ Volume: //')" ;;
                *"Cancel"*) continue ;;
            esac

            # Step 2: Filter
            local filter_opts="--max-depth 1"
            local type_label=$(gum choose --header=" Filter Type" --limit=1 \
                " All Files" " Recursive" " Images" " Videos" \
                " Documents" " Huge (>100M)" " Old (>30d)")
            
            case "$type_label" in
                *"Recursive"*) filter_opts=""; prompt_str=" $target_label > " ;;
                *"Images"*) filter_opts="-e png -e jpg -e jpeg -e webp -e heic"; prompt_str=" Images > " ;;
                *"Videos"*) filter_opts="-e mp4 -e mov -e mkv -e avi"; prompt_str=" Videos > " ;;
                *"Documents"*) filter_opts="-e pdf -e doc -e docx -e xls -e ppt -e md -e txt"; prompt_str=" Docs > " ;;
                *"Huge"*) filter_opts="--size +100M"; prompt_str=" Huge > " ;;
                *"Old"*) filter_opts="--change-older-than 30days"; prompt_str=" Old > " ;;
                *) prompt_str=" $target_label > " ;;
            esac
            
            current_cmd="$base_fd $filter_opts . \"$target_path\""
            continue

        elif [[ -n "$selection" ]]; then
            # Execution
            echo "$selection" | tr '\n' '\0' | xargs -0 -r trash-put
            [ $? -eq 0 ] && echo ""
            break
        else
            break
        fi
    done
}

# Helper
function _run_del_loop() {
    eval "$1" | fzf -m --height 80% --layout=reverse --border --prompt="$2" \
        --header="Enter: Delete / Tab: Select" \
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

# --- 📝 Smart Editor ---
function edit() {
    local file="${1:-.}"
    if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
        gum style --foreground 33 "🚀 VS Code: $file"; code "$file"
    else
        gum style --foreground 150 "⚡ Neovim: $file"; nvim "$file"
    fi
}

# --- 🎮 Dashboard (dev) ---
function dev() {
    local mode="GLOBAL"; local color="39"
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 && mode="PROJECT" && color="214"
    echo ""; gum style --foreground "$color" --bold --border double --padding "0 2" "🧭 COCKPIT COMMANDER"
    local selected=""
    if [ "$mode" = "PROJECT" ]; then
        selected=$(gum choose --cursor="👉 " --selected.foreground="$color" \
            "🚀 Work" "🏁 Finish" "💬 Commit" "🤖 Ask AI" "🕹️  Git" "🔙 Exit Project")
    else
        selected=$(gum choose --cursor="👉 " --selected.foreground="$color" \
            "📂 Jump" "✨ New" "🤖 Ask AI" "🛠️  Update" "📦 Install" "🏥 Check" "🧹 Clean" "🔑 Save Key")
    fi
    case "$selected" in
        *"Work"*) work ;; *"Finish"*) finish-work ;; *"Commit"*) gcm ;;
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
        "w"|"work") work "$@" ;; "n"|"new") mkproj "$@" ;; "f"|"fin") finish-work ;;
        "go"|"p") p ;; "e"|"edit") edit "$@" ;; "ai"|"ask") ask "$@" ;;
        "g"|"git") lazygit ;; "z"|"zj") zellij ;; "up") nix-up ;;
        "fix") sz ;; "del") del "$@" ;; "undo") undo ;;
        *) echo "❌ Unknown: c $subcmd" ;;
    esac
}
