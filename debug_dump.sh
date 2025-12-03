#!/bin/bash
timestamp=$(date "+%Y%m%d_%H%M%S")
outfile="$HOME/Desktop/cockpit_debug_${timestamp}.txt"
echo "🩺 Running diagnosis... Output: $outfile"

{
    echo "=== SYSTEM INFO ==="
    echo "Hostname: $(scutil --get LocalHostName)"
    echo "User: $(whoami)"
    echo "Home: $HOME"
    echo "Nix Version: $(nix --version)"
    echo ""

    echo "=== FILE TREE ==="
    if command -v eza >/dev/null; then
        eza --tree --level=4 -a -I ".git|node_modules|.DS_Store|.cache" "$HOME/dotfiles"
    else
        find "$HOME/dotfiles" -maxdepth 4 -not -path '*/.*'
    fi
    echo ""
    
    echo "=== WRAPPER APPS ==="
    ls -lR ~/Applications/yabai-wrapper.app 2>/dev/null || echo "yabai-wrapper not found"
    ls -lR ~/Applications/skhd-wrapper.app 2>/dev/null || echo "skhd-wrapper not found"
    echo ""

    echo "=== SERVICE STATUS ==="
    launchctl list | grep -E 'yabai|skhd' || echo "No services running"
    echo ""

    echo "=== FILE CONTENTS ==="
    # 読み込むファイルリスト
    files=(
        "$HOME/dotfiles/flake.nix"
        "$HOME/dotfiles/home.nix"
        "$HOME/dotfiles/nix/pkgs.nix"
        "$HOME/dotfiles/nix/modules/shell.nix"
        "$HOME/dotfiles/nix/modules/zsh.nix"
        "$HOME/dotfiles/nix/modules/darwin.nix"
        "$HOME/dotfiles/nix/modules/window_manager.nix"
        "$HOME/dotfiles/zsh/cockpit_logic.zsh"
    )

    for f in "${files[@]}"; do
        if [ -f "$f" ]; then
            echo ">>> FILE: $f"
            cat "$f"
            echo -e "\n<<< END OF FILE\n"
        else
            echo ">>> FILE: $f (NOT FOUND)"
            echo ""
        fi
    done

} > "$outfile"

echo "✅ Diagnosis Dump Created!"
