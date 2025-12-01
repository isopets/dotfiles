{ config, pkgs, ... }:

{
  # --- 1. Zsh (Immutable ZshRC) ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    # 最終修正: initExtra に .zshrc の全ロジックを直接埋め込む
    initExtra = ''
      export DOTFILES="$HOME/dotfiles"
      export PATH="$HOME/.nix-profile/bin:$PATH"
      setopt +o nomatch
      setopt interactivecomments

      [ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"
      
      if [ -d "$DOTFILES/zsh/functions" ]; then
        for f in "$DOTFILES/zsh/functions/"*.zsh; do
          [ -r "$f" ] && source "$f"
        done
      fi

      alias ai="ask"
      command -v starship >/dev/null && eval "$(starship init zsh)"
      command -v direnv >/dev/null && eval "$(direnv hook zsh)"
    '';
  };

  # --- 2. Tools & Integrations ---
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };
  programs.git = {
    enable = true;
    userName = "isopets";
    userEmail = "jandp.0717@gmail.com";
  };
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ../../config/starship.toml;
  fonts.fontconfig.enable = true;
}