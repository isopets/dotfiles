# 引数に pkgs-unstable を追加
{ config, pkgs, pkgs-unstable, ... }:

{
  # --- 1. Magical History (Atuin) ---
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

  # --- 2. Core Tools ---
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
    delta = {
      enable = true;
      options = {
        side-by-side = true;
        line-numbers = true;
        theme = "Dracula";
      };
    };
    extraConfig = {
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };

  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ../../config/starship.toml;
  fonts.fontconfig.enable = true;
  
  # --- 3. Packages ---
  home.packages = with pkgs; [
    zsh-fzf-tab
    trash-cli
    shellcheck
    shfmt
    zellij
    
    # 🚨 ここ！ pkgs-unstable から Sheldon を入れる
    pkgs-unstable.sheldon 
  ];
}
