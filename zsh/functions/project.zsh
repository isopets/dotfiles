function mkproj() {
    if [ -z "$1" ] || [ -z "$2" ]; then echo "❌ Usage: mkproj <Category> <Name>"; return 1; fi
    local c="$1"; local n="$2"
    local p="$REAL_CODE_DIR/$c/$n"
    local a="$REAL_ASSETS_DIR/$c/$n"; local para="$PARA_DIR/1_Projects/$n"

    mkdir -p "$p/.vscode"
    mkdir -p "$a"/{Design,Video,Export}
    mkdir -p "$para"

    ln -s "$a" "$p/_GoToCreative"
    ln -s "$p" "$a/_GoToCode"
    ln -s "$p" "$para/💻_Code"
    ln -s "$a" "$para/🎨_Assets"

    git -C "$p" init
    echo "# $n" > "$p/README.md"
    echo "✨ Created $n"
    cd "$p"
}

function work() {
    local n="$1"
    if [ -z "$1" ]; then
        n=$(ls "$PARA_DIR/1_Projects" | fzf --prompt="🚀 Launch > ")
        if [ -z "$n" ]; then return 1; fi
    fi
    local p="$PARA_DIR/1_Projects/$n"
    local r=$(readlink "$p/💻_Code")
    
    if [ -d "$r" ]; then
        echo "🚀 Launching: $n"
        cd "$r"
        if [ -d "$p/🎨_Assets" ]; then open "$p/🎨_Assets"; fi
        code "$r"
    fi
}
alias done="finish-work"
