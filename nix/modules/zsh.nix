{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Nix管理の不変エイリアス
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

    # 🚨 修正: initExtra -> initContent に変更 (最新仕様)
    initContent = ''
      # 1. FZF-Tab Integration
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # 2. Load Cockpit Logic (Direct Link)
      if [ -f "$HOME/dotfiles/zsh/cockpit_logic.zsh" ]; then
        source "$HOME/dotfiles/zsh/cockpit_logic.zsh"
      else
        echo "⚠️ Cockpit Logic not found!"
      fi
    '';
  };
}
