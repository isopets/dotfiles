# =================================================================
# 🎮 Cockpit Core (Final Stable Code)
# =================================================================
# System Context
export DOTFILES="$HOME/dotfiles"
export PATH="$HOME/.nix-profile/bin:$PATH"
setopt +o nomatch
setopt interactivecomments

# --- Safety ---
alias rm="echo '⛔️ Use \"del\" (trash)'; false"
alias del="trash-put"

# --- Core Functions ---

## Smart Editor
function edit() {
    local file="${1:-.}"
    if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
        gum style --foreground 33 "🚀 VS Code: $file"; code "$file"
    else
        gum style --foreground 150 "⚡ Neovim: $file"; nvim "$file"
    fi
}

## Reload Shell
function sz() {
    echo "🧹 Cleaning environment..."
    for f in "$HOME/dotfiles/zsh/src/"*.zsh; do
        [ -f "$f" ] && tr -cd '\11\12\40-\176' < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    done
    echo "🔄 Reloading Shell..."
    exec zsh
}

## Dashboard (Interactive Menu)
function dev() {
    local mode="GLOBAL"
    local color="39" # Blue

    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        mode="PROJECT"
        color="214" # Orange
    fi

    echo ""
    gum style --foreground "$color" --bold --border double --padding "0 2" "🧭 COCKPIT COMMANDER"
    echo ""

    local selected=""
    if [ "$mode" = "PROJECT" ]; then
        selected=$(gum choose --cursor="👉 " --selected.foreground="$color" --height 10 \
            "🚀 Work      (Start Work)" \
            "🏁 Finish    (Save & Close)" \
            "💬 Commit    (AI Auto-Gen)" \
            "🤖 Ask AI    (Chat)" \
            "🕹️  Git       (Lazygit)" \
            "🔙 Exit Project")
    else
        selected=$(gum choose --cursor="👉 " --selected.foreground="$color" --height 12 \
            "📂 Jump      (Open Project)" \
            "✨ New       (Create Project)" \
            "🤖 Ask AI    (Chat)" \
            "🛠️  Update    (System Update)" \
            "📦 Install   (Add Package)" \
            "🏥 Check     (Audit)" \
            "🧹 Clean     (Detox)" \
            "🔑 Save Key  (Bitwarden)")
    fi

    case "$selected" in
        *"Work"*)    work ;;
        *"Finish"*)  finish-work ;;
        *"Commit"*)  gcm ;;
        *"Ask AI"*)  echo -n "🤖 Q: "; read q; ask "$q" ;;
        *"Git"*)     lazygit ;;
        *"Exit"*)    cd ~; dev ;;
        
        *"Jump"*)    p ;;
        *"New"*)     mkproj ;;
        *"Update"*)  nix-up ;;
        *"Install"*) nix-add ;;
        *"Check"*)   audit ;;
        *"Clean"*)   cleanup ;;
        *"Save Key"*) save-key ;;
    esac
}

## Omni Command (Fixed)
function c() {
    # 🚨 修正: 引数がない場合は即座に dev を呼び出し、shift をスキップ
    if [ $# -eq 0 ]; then
        dev
        return
    fi

    local subcmd="$1"; shift
    case "$subcmd" in
        "w"|"work") work "$@" ;;
        "n"|"new")  mkproj "$@" ;;
        "f"|"fin")  finish-work ;;
        "go"|"p")   p ;;
        "e"|"edit") edit "$@" ;;
        "ai"|"ask") ask "$@" ;;
        "ap")       ask-project "$@" ;;
        "l"|"log")  log "$@" ;;
        "g"|"git")  lazygit ;;
        "z"|"zj")   zellij ;;
        "up")       nix-up ;;
        "check")    audit ;;
        "clean")    cleanup ;;
        "fix")      sz ;;
        "b")        briefing ;;
        "sk")       save-key ;;
        "dump")     dump-context "$@" ;;
        "snap")     snapshot "$@" ;;
        "migrate")  migrate-tools "$@" ;;
        *) echo "❌ Unknown: c $subcmd" ;;
    esac
}

# Basic Aliases
alias d="c"
alias e="edit"
alias sz="exec zsh"
# --- 🗑️ Cockpit Adaptive Delete (Multi-Disk & Granular) ---
function del() {
    # -------------------------------------------
    # 0. Engine Setup
    # -------------------------------------------
    local base_fd="fd --type f --hidden --follow --exclude .git"

    # Direct Mode (引数ありなら即実行)
    if [ $# -gt 0 ]; then
        # ... (前回のDirect Modeロジックを維持しても良いが、今回はWizardに集中するため省略可能だが、利便性のため残す)
        local d_cmd="$base_fd"
        [[ "$1" == "." ]] && d_cmd="$base_fd --max-depth 1"
        [[ "$1" == "-r" ]] && d_cmd="$base_fd"
        _run_del_fzf "$d_cmd . $1" "🎯 Direct > "
        return
    fi

    # -------------------------------------------
    # 1. Scope Selection (場所: 外付け含む)
    # -------------------------------------------
    local target_path="."
    
    # 接続されているボリュームリストを動的に生成
    local volumes=$(ls -d /Volumes/* 2>/dev/null | grep -v "Macintosh HD" | xargs -I {} basename "{}")
    local vol_menu=""
    if [ -n "$volumes" ]; then
        # 外付けがある場合のみメニューに追加
        while read -r vol; do
            vol_menu+="💾 Volume: $vol"$'\n'
        done <<< "$volumes"
    fi

    local place_label=$(gum choose --header="📍 Step 1: Target Scope" --limit=1 \
        "📂 Current Directory" \
        "🗺️  Browse Folder... (Finder Mode)" \
        "🚀 Project Root" \
        "⬇️  Downloads" \
        "🖥️  Desktop" \
        "🏠 Home (User)" \
        "$vol_menu" \
        "❌ Cancel")

    if [[ -z "$place_label" || "$place_label" == *"Cancel"* ]]; then return; fi

    case "$place_label" in
        *"Current"*)   target_path="." ;;
        *"Project"*)   target_path=$(git rev-parse --show-toplevel 2>/dev/null || echo ".") ;;
        *"Downloads"*) target_path="$HOME/Downloads" ;;
        *"Desktop"*)   target_path="$HOME/Desktop" ;;
        *"Home"*)      target_path="$HOME" ;;
        *"Volume:"*)   
            # 選択されたボリューム名を抽出してパス化
            local vname=$(echo "$place_label" | sed 's/💾 Volume: //')
            target_path="/Volumes/$vname" 
            ;;
        *"Browse"*)    target_path=$(gum file --directory --height=15 "$HOME" /Volumes) ;;
    esac

    # -------------------------------------------
    # 2. Filter Selection (条件: 階層化)
    # -------------------------------------------
    local filter_opts="--max-depth 1"
    local prompt_icon="📂"

    local type_label=$(gum choose --header="🔍 Step 2: What are we looking for?" --limit=1 \
        "🌈 All Files (Here)" \
        "🌍 Recursive (Deep)" \
        "🐘 File Size (Large Files)" \
        "📅 Old Files (Cleanup)" \
        "🖼️  Media (Images/Videos)" \
        "📄 Documents (PDF/Docs)" \
        "📦 Archives (Zip/Iso)")

    if [[ -z "$type_label" ]]; then return; fi

    case "$type_label" in
        *"All"*)       filter_opts="--max-depth 1" ;;
        *"Recursive"*) filter_opts="" ;;
        
        # --- 🐘 Size Sub-Menu (自由と秩序) ---
        *"Size"*)
            prompt_icon="🐘"
            local size_sel=$(gum choose --header="🐘 Select Size Threshold" --limit=1 \
                "🔹 > 100 MB" \
                "🔸 > 500 MB" \
                "🔶 > 1 GB" \
                "🔴 > 10 GB" \
                "✏️  Custom Size...")
            
            case "$size_sel" in
                *"100 MB"*) filter_opts="--size +100M" ;;
                *"500 MB"*) filter_opts="--size +500M" ;;
                *"1 GB"*)   filter_opts="--size +1G" ;;
                *"10 GB"*)  filter_opts="--size +10G" ;;
                *"Custom"*) 
                    local inp=$(gum input --placeholder "e.g. 50M, 2G, 500k")
                    [ -z "$inp" ] && return
                    filter_opts="--size +$inp" ;;
                *) return ;;
            esac
            ;;

        # --- 📅 Time Sub-Menu (自由と秩序) ---
        *"Old"*)
            prompt_icon="📅"
            local time_sel=$(gum choose --header="📅 Select Time Threshold" --limit=1 \
                "🌙 > 30 Days ago" \
                "❄️  > 3 Months ago" \
                "🎂 > 1 Year ago" \
                "✏️  Custom Time...")
            
            case "$time_sel" in
                *"30 Days"*)   filter_opts="--change-older-than 30days" ;;
                *"3 Months"*)  filter_opts="--change-older-than 90days" ;;
                *"1 Year"*)    filter_opts="--change-older-than 1years" ;;
                *"Custom"*)
                    local inp=$(gum input --placeholder "e.g. 2weeks, 10d, 2023-01-01")
                    [ -z "$inp" ] && return
                    filter_opts="--change-older-than $inp" ;;
                *) return ;;
            esac
            ;;

        *"Media"*)     filter_opts="-e png -e jpg -e jpeg -e webp -e mp4 -e mov -e mkv" ;;
        *"Documents"*) filter_opts="-e pdf -e doc -e docx -e xls -e ppt -e txt -e md" ;;
        *"Archives"*)  filter_opts="-e zip -e rar -e 7z -e tar -e gz -e dmg -e iso" ;;
    esac

    # -------------------------------------------
    # 3. Execution (fzf)
    # -------------------------------------------
    local final_cmd="$base_fd $filter_opts . \"$target_path\""
    _run_del_fzf "$final_cmd" "$prompt_icon Delete > "
}
