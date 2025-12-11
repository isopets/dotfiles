# --- 10_project.zsh : Work & Code ---

# Omni-Creator (DevOps Edition)
function mkproj() {
    local n="$1"; [ -z "$n" ] && n=$(gum input --placeholder "Project Name")
    [ -z "$n" ] && return 1
    local s=$(gum choose "🐍 Python" "🌐 Web/Node" "🦀 Rust" "🐹 Go" "📂 Blank")
    [ -z "$s" ] && return 1

    local p="$HOME/PARA/1_Projects/$n/_Code"
    if [ -d "$p" ]; then copen "$p"; return; fi
    
    mkdir -p "$p" "$HOME/PARA/1_Projects/$n/_Docs" "$HOME/PARA/1_Projects/$n/_Assets"
    git init "$p" >/dev/null; cd "$p"

    case "$s" in
        *"Python"*) 
            uv init >/dev/null 2>&1; uv add --dev mypy ruff >/dev/null 2>&1
            echo 'def main():\n    print("Hello")\nif __name__ == "__main__":\n    main()' > main.py
            echo 'run:\n\tuv run main.py\ncheck:\n\tuv run ruff check .' > Justfile ;;
        *"Web"*) npm init -y >/dev/null 2>&1; echo 'run:\n\tnpm run dev' > Justfile ;;
        *"Rust"*) cargo init >/dev/null 2>&1; echo 'run:\n\tcargo run' > Justfile ;;
        *"Go"*) go mod init "$n" >/dev/null 2>&1; echo 'package main\nfunc main(){}' > main.go ;;
        *) touch README.md ;;
    esac
    echo "# $n" > README.md; echo "✅ Created: $n"; copen .
}

# Work Mode
function work() {
    local n="$1"
    [ -z "$n" ] && n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="🚀 Work > " --layout=reverse)
    [ -z "$n" ] && return 1
    local p="$HOME/PARA/1_Projects/$n/_Code"
    [ ! -d "$p" ] && echo "❌ 404" && return 1
    echo "🚀 Work: $n"; copen "$p"
}

# Architect
function mklang() {
    local l="$1"; [ -z "$l" ] && l=$(gum input --placeholder "Language")
    [ -z "$l" ] && return 1
    local p="[Lang] $l"; mkdir -p "$HOME/dotfiles/vscode/profiles/$p"
    echo "✅ Profile: $p (Run 'up' to install packages)"
}

# Jump
function p() {
    local n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="📂 Jump > ")
    [ -n "$n" ] && cd "$HOME/PARA/1_Projects/$n" && ls -F
}
