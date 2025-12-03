{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "eza --icons --git";
      cat = "bat";
      grep = "rg";
      find = "fd";
      vi = "nvim";
      vim = "nvim";
      cp = "cp -i";
      mv = "mv -i";
    };

    initExtra = ''
      # FZF-Tab
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      
      # Live-Link Logic
      if [ -f "$HOME/dotfiles/zsh/cockpit_logic.zsh" ]; then
        source "$HOME/dotfiles/zsh/cockpit_logic.zsh"
      fi
    '';
  };
}
