function _self-clean() {
    for f in "$HOME/dotfiles/zsh/"{functions,config}/*.zsh; do
        [ -f "$f" ] && tr -cd '\11\12\40-\176' < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    done
}
function sz() { _self-clean; exec zsh; }
