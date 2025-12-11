# =================================================================
# 🚀 Cockpit Productivity Plus (v9.0 Full Restoration)
# =================================================================

# --- 1. Context-Aware Launcher (copen) ---
function copen() {
    setopt local_options nullglob
    local target="${1:-.}"
    local context_dir="$target"
    if [ -f "$target" ]; then context_dir=$(dirname "$target"); fi

    local profile=""
    if [ -f "$context_dir/.cockpit_profile" ]; then profile=$(cat "$context_dir/.cockpit_profile")
    elif [ -n "$(ls "$context_dir"/*.py 2>/dev/null)" ] || [ -f "$context_dir/pyproject.toml" ]; then profile="[Lang] Python"
    elif [ -f "$context_dir/package.json" ]; then profile="[Lang] Web"
    elif [ -f "$context_dir/Cargo.toml" ]; then profile="[Lang] Rust"
    elif [ -f "$context_dir/go.mod" ]; then profile="[Lang] Go"
    else profile="[Base] Common"; fi

    if ! code --list-profiles | grep -q "$profile"; then profile="[Base] Common"; fi
    echo "🚀 Launching with: $profile"
    code --profile "$profile" "$target"
}

# --- 2. The Omni-Creator (mkproj) ---
function mkproj() {
    local name="$1"; local stack="$2"
    if [ -z "$name" ]; then name=$(gum input --placeholder "Project Name"); fi
    [ -z "$name" ] && return 1
    if [ -z "$stack" ]; then stack=$(gum choose "🐍 Python" "🌐 Web/Node" "🦀 Rust" "🐹 Go" "📂 Blank"); fi
    [ -z "$stack" ] && return 1

    local p="$HOME/PARA/1_Projects/$name/_Code"
    if [ -d "$p" ]; then copen "$p"; return; fi
    mkdir -p "$p" "$HOME/PARA/1_Projects/$name/_Docs" "$HOME/PARA/1_Projects/$name/_Assets"
    git init "$p" >/dev/null; cd "$p"

    case "$stack" in
        *"Python"*) uv init >/dev/null 2>&1; echo 'run:\n\tuv run main.py' > Justfile; echo 'print("Hello")' > main.py ;;
        *"Web"*) npm init -y >/dev/null 2>&1; echo 'run:\n\tnpm run dev' > Justfile ;;
        *"Rust"*) cargo init >/dev/null 2>&1; echo 'run:\n\tcargo run' > Justfile ;;
        *"Go"*) go mod init "$name" >/dev/null 2>&1; echo 'package main\nfunc main(){}' > main.go; echo 'run:\n\tgo run main.go' > Justfile ;;
        *) touch README.md ;;
    esac
    copen .
}

# --- 3. The Architect (mklang) ---
function mklang() {
    local l="$1"; [ -z "$l" ] && l=$(gum input --placeholder "Language Name")
    [ -z "$l" ] && return
    local pkgs=$(ask "Nix packages for $l? (Space separated)")
    if gum confirm "Install $pkgs?"; then
        for p in ${(s: :)pkgs}; do sed -i '' "/^  ];/i \\    $p" "$HOME/dotfiles/nix/pkgs.nix" 2>/dev/null || sed -i "/^  ];/i \\    $p" "$HOME/dotfiles/nix/pkgs.nix"; done
        (nix-up >/dev/null &)
    fi
    local exts=$(ask "VS Code extensions for $l? (3 IDs)")
    if gum confirm "Install extensions?"; then
        for e in ${(s: :)exts}; do code --profile "[Lang] $l" --install-extension "$e" >/dev/null; done
    fi
}

# --- 4. Project Localizer (mklocal) ---
function mklocal() {
    local n=${PWD##*/}; local p="[Proj] $n"
    mkdir -p "$HOME/dotfiles/vscode/profiles/$p"
    echo "{\"workbench.colorCustomizations\":{\"activityBar.background\":\"#ff5c5c\"},\"window.title\":\"\${dirty} [🔒 LOCAL] \${activeEditorMedium}\"}" > "$HOME/dotfiles/vscode/profiles/$p/settings.json"
    echo "$p" > .cockpit_profile
    copen .
}

# --- 5. Async App Installer (app) ---
function app() {
    local q="$1"; [ -z "$q" ] && q=$(gum input); [ -z "$q" ] && return
    local s=$(brew search --cask "$q" | grep -v "==>" | gum filter)
    [ -z "$s" ] && return
    local c="$HOME/dotfiles/nix/modules/darwin.nix"
    if ! grep -q "\"$s\"" "$c"; then
        sed -i '' "/casks =/s/\];/ \"$s\" \];/" "$c" 2>/dev/null || sed -i "/casks =/s/\];/ \"$s\" \];/" "$c"
    fi
    zellij action new-tab --name "📦 $s" --cwd "$HOME" -- zsh -c "echo '🔑 Auth...'; sudo -v; if sudo ~/dotfiles/scripts/cockpit-update.sh; then osascript -e 'display notification \"Installed: $s\"'; sleep 3; zellij action close-tab; else echo '❌ Failed.'; read; fi"
}

# --- 6. Universal Runner (run) ---
function run() {
    local c=""
    if [ -f "Justfile" ] || [ -f "justfile" ]; then [ -n "$1" ] && c="just $@" || c="just $(just --summary | tr ' ' '\n' | gum choose)"
    elif [ -f "package.json" ] && grep -q '"dev":' package.json; then c="npm run dev"
    elif [ -f "main.py" ]; then c="python main.py"
    else echo "🤔 No runnable config."; return; fi
    [ -z "$c" ] && return
    echo "🚀 $c"; eval "$c" || { echo "💥 Failed."; gum confirm "🔥 Fix?" && ask "Fix error:\n$c"; }
}

# --- 7. Neuro & Utils ---
function play() {
    local l="$1"; [ -z "$l" ] && l=$(gum input)
    local d="Play_${l}_$(date +%H%M%S)"; local p="$HOME/PARA/0_Inbox/Playground/$d"; mkdir -p "$p"; cd "$p"
    case "$l" in
        "python"|"py") uv init >/dev/null 2>&1; echo 'run:\n\tuv run main.py' > Justfile; echo 'print("🧪 Python")' > main.py ;;
        "web"|"js") npm init -y >/dev/null 2>&1; echo 'run:\n\tnode index.js' > Justfile; echo 'console.log("🧪 JS")' > index.js ;;
        *) touch scratch.txt ;;
    esac
    copen .
}
function flow() {
    if [ "$1" = "off" ]; then echo "🌅 Flow Ended."; return; fi
    echo "🌊 Flow State: ON"; pkill "Slack"; pkill "Discord"
    clear; echo -e "\n\033[1;36m   🌊 ZONE ENTERED \033[0m\n"
}

# Utilities
function mkjust() { [ -f "Justfile" ] && return; ask "Create Justfile for:\n$(ls -F)" > Justfile; }
function snapshot() { local p=$(find "$HOME/dotfiles/vscode/profiles" -maxdepth 1 -type d | sed "s|$HOME/dotfiles/vscode/profiles/||" | grep -v "^$" | gum filter); [ -z "$p" ] && return; code --profile "$p" --list-extensions > "$HOME/dotfiles/vscode/profiles/$p/extensions.txt"; echo "✅ Saved"; }
function memo() { local n="${1:-Note_$(date +%Y-%m-%d_%H-%M-%S).md}"; mkdir -p ~/PARA/0_Inbox; code "$HOME/PARA/0_Inbox/$n"; }
function scratch() { memo SCRATCH.md; }
function tmp() { local p="$HOME/PARA/0_Inbox/Tmp/$(date +%Y-%m-%d)"; mkdir -p "$p"; cd "$p"; echo "📂 Tmp: $p"; }
function pastefile() { local n="${1:-clipboard_$(date +%H-%M-%S).txt}"; pbpaste > "$n"; echo "✅ Saved: $n"; }

# Aliases
alias code="copen"
alias start="run"
alias pl="play"
alias pf="pastefile"
alias zone="flow"
alias wtf="explain"
