## System Update
function nix-up() {
    local dir="$HOME/dotfiles"
    git -C "$dir" add .
    if [ -n "$(git -C "$dir" diff --cached)" ]; then
        echo " Auto-committing..."
        git -C "$dir" commit -m "chore(nix): update config"
    fi
    echo " Updating..."
    if nh darwin switch "$dir"; then
        echo " Done."
        exec zsh
    else
        echo " Failed."
    fi
}

## Add Package
function nix-add() {
    local pkg="$1"; [ -z "$pkg" ] && pkg=$(gum input --prompt=" Package: ")
    [ -z "$pkg" ] && return 1
    sed -i "" "/^  ];/i \\    $pkg" "$HOME/dotfiles/nix/pkgs.nix"
    echo " Added $pkg"
    nix-up
}
alias up="nix-up"
