{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # エイリアス定義
    shellAliases = {
      d = "dev";
      w = "work";
      m = "mkproj";
      f = "finish-work";
      a = "ask";
      c = "gcm";
      e = "edit";
      g = "lazygit";
      l = "eza -la --icons --git";
      cat = "bat";
      z = "zoxide";
      ".." = "cd ..";
    };

    # .zshrc の本体（ここだけにする）
    initExtra = ''
      export DOTFILES="$HOME/dotfiles"
      export PATH="$HOME/.nix-profile/bin:$PATH"
      setopt +o nomatch
      setopt interactivecomments

      # Secrets
      [ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"

      # Functions
      if [ -d "$DOTFILES/zsh/functions" ]; then
        for f in "$DOTFILES/zsh/functions/"*.zsh; do
          [ -r "$f" ] && source "$f"
        done
      fi

      # Tools
      alias ai="ask"
      command -v starship >/dev/null && eval "$(starship init zsh)"
      command -v direnv >/dev/null && eval "$(direnv hook zsh)"
    '';
  };
}