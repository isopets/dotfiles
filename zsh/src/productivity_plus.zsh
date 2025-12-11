# =================================================================
# 🚀 Cockpit Productivity Plus (v9.1 Loop Fix)
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

    # プロファイル実体チェック
    if ! command code --list-profiles | grep -q "$profile"; then profile="[Base] Common"; fi
    
    echo "🚀 Launching with: $profile"
    
    # 【修正ポイント】 'command' をつけてエイリアスループを回避！
    command code --profile "$profile" "$target"
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

# --- 3. The Architect (mklang) [Neuro-Design Edition] ---
function mklang() {
    local lang="$1"
    [ -z "$lang" ] && lang=$(gum input --placeholder "Language Name")
    [ -z "$lang" ] && return

    echo "🏗️ Architecting for: $lang"
    echo "🧠 Select Cognitive Mode:"
    local mode=$(gum choose "🧠 Deep Focus (Blue)" "✨ Creative Flow (Purple)" "🌿 Steady Growth (Green)" "🛡️ Solid Structure (Orange)")
    
    local color="#4ec9b0" # default blue
    case "$mode" in *"Purple"*) color="#c586c0";; *"Green"*) color="#6a9955";; *"Orange"*) color="#ce9178";; esac

    local pkgs=$(ask "Nix packages for $lang?")
    if [ -n "$pkgs" ] && gum confirm "Install $pkgs?"; then
        for p in ${(s: :)pkgs}; do sed -i '' "/^  ];/i \\    $p" "$HOME/dotfiles/nix/pkgs.nix" 2>/dev/null || sed -i "/^  ];/i \\    $p" "$HOME/dotfiles/nix/pkgs.nix"; done
        (nix-up >/dev/null &)
    fi

    # Profile Creation
    local pname="[Lang] $lang"
    mkdir -p "$HOME/dotfiles/vscode/profiles/$pname"
    echo "{\"workbench.colorCustomizations\":{\"activityBar.background\":\"$color\",\"titleBar.activeBackground\":\"$color\"},\"window.title\":\"\${dirty} [ $lang ] \${activeEditorMedium}\"}" > "$HOME/dotfiles/vscode/profiles/$pname/settings.json"
    
    local exts=$(ask "VS Code extensions for $lang?")
    if [ -n "$exts" ] && gum confirm "Install extensions?"; then
        for e in ${(s: :)exts}; do command code --profile "$pname" --install-extension "$e" >/dev/null; done
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

# --- 7. Neuro & Utils (play, flow) ---
function play() {
    local lang="$1"
    if [ -z "$lang" ]; then lang=$(gum input --placeholder "Language"); fi
    [ -z "$lang" ] && return

    local d="Play_${lang}_$(date +%H%M%S)"; local p="$HOME/PARA/0_Inbox/Playground/$d"; mkdir -p "$p"; cd "$p"
    
    case "$lang" in
        "python"|"py") uv init >/dev/null 2>&1; echo 'run:\n\tuv run main.py' > Justfile; echo 'print("🧪 Python")' > main.py ;;
        "web"|"js") npm init -y >/dev/null 2>&1; echo 'run:\n\tnode index.js' > Justfile; echo 'console.log("🧪 JS")' > index.js ;;
        *) 
            # AI Auto-Gen
            echo "✨ Asking AI for $lang boilerplate..."
            local res=$(ask "Create Hello World & Justfile for $lang. Output format: shell script to create files. No markdown.")
            if [ -n "$res" ]; then eval "$res"; else touch scratch.txt; fi
            ;;
    esac
    copen .
}

function flow() {
    if [ "$1" = "off" ]; then echo "🌅 Flow Ended."; return; fi
    echo "🌊 Flow State: ON"; pkill "Slack"; pkill "Discord"
    clear; echo -e "\n\033[1;36m   🌊 ZONE ENTERED \033[0m\n"
}

# --- Helpers ---
function ask() {
    local p="$*"
    [ -z "$p" ] && p=$(gum input --placeholder "Ask AI...")
    if [ -f "$HOME/dotfiles/scripts/ask_ai.py" ]; then python3 "$HOME/dotfiles/scripts/ask_ai.py" "$p"; else echo "echo 'AI Unavailable'"; fi
}
function nix-up() { [ -f "$HOME/dotfiles/scripts/cockpit-update.sh" ] && sudo "$HOME/dotfiles/scripts/cockpit-update.sh"; }
function mkjust() { [ -f "Justfile" ] && return; ask "Create Justfile for:\n$(ls -F)" > Justfile; }
function snapshot() { local p=$(find "$HOME/dotfiles/vscode/profiles" -maxdepth 1 -type d | sed "s|$HOME/dotfiles/vscode/profiles/||" | grep -v "^$" | gum filter); [ -z "$p" ] && return; command code --profile "$p" --list-extensions > "$HOME/dotfiles/vscode/profiles/$p/extensions.txt"; echo "✅ Saved"; }
function memo() { local n="${1:-Note_$(date +%Y-%m-%d_%H-%M-%S).md}"; mkdir -p ~/PARA/0_Inbox; copen "$HOME/PARA/0_Inbox/$n"; }
function scratch() { memo SCRATCH.md; }
function tmp() { local p="$HOME/PARA/0_Inbox/Tmp/$(date +%Y-%m-%d)"; mkdir -p "$p"; cd "$p"; echo "📂 Tmp: $p"; }
function pastefile() { local n="${1:-clipboard_$(date +%H-%M-%S).txt}"; pbpaste > "$n"; echo "✅ Saved: $n"; }
# --- 8. Ambience (Restored) ---
function ambience() {
    local s="$1"
    if [ -z "$s" ]; then s=$(gum choose "🌧️ Rain" "🔥 Fire" "☕ Cafe" "🌊 Ocean" "🔇 Stop"); fi
    pkill "afplay" 2>/dev/null
    case "$s" in
        *"Rain"*) echo "🌧️ Rain..."; open "https://mynoise.net/NoiseMachines/rainNoiseGenerator.php" ;;
        *"Fire"*) echo "🔥 Fire..."; open "https://mynoise.net/NoiseMachines/fireNoiseGenerator.php" ;;
        *"Stop"*) echo "🔇 Stopped." ;;
        *) echo "☕ Enjoy." ;;
    esac
}
