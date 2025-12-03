{ config, pkgs, pkgs-unstable, ... }:

{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      search_mode = "fuzzy";
      style = "compact";
    };
  };

  programs.direnv = { enable = true; nix-direnv.enable = true; };
  programs.mise = { enable = true; enableZshIntegration = true; };
  programs.zoxide = { enable = true; enableZshIntegration = true; options = ["--cmd cd"]; };

  programs.git = {
    enable = true;
    userName = "isopets";
    userEmail = "jandp.0717@gmail.com";
    delta = {
      enable = true;
      options = { side-by-side = true; line-numbers = true; theme = "Dracula"; };
    };
    extraConfig = { pull.rebase = false; init.defaultBranch = "main"; };
  };

  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ../../config/starship.toml;
  fonts.fontconfig.enable = true;
  
  home.packages = with pkgs; [
    zsh-fzf-tab
    trash-cli
    shellcheck
    shfmt
    zellij
    bottom
    pre-commit
    
    pkgs-unstable.nh # Darwin対応版
    pkgs-unstable.sheldon
    pkgs-unstable.bitwarden-cli
    pkgs-unstable.yazi
    pkgs-unstable.navi
    pkgs-unstable.just
  ];
}
