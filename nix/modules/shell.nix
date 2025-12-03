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

  # --- 2. Core Integrations ---
  programs.direnv = { enable = true; nix-direnv.enable = true; };
  programs.mise = { enable = true; enableZshIntegration = true; };
  programs.zoxide = { enable = true; enableZshIntegration = true; options = ["--cmd cd"]; };

  # --- 3. Git & Delta (Modernized) ---
  programs.git = {
    enable = true;
    # 🚨 修正: userName/Email は settings.user 配下に移動
    settings = {
      user = {
        name = "isopets";
        email = "jandp.0717@gmail.com";
      };
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };

  # �� 修正: Delta は独立した programs.delta として設定
  programs.delta = {
    enable = true;
    options = {
      side-by-side = true;
      line-numbers = true;
      theme = "Dracula";
    };
  };

  # --- 4. UI & Fonts ---
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ../../config/starship.toml;
  fonts.fontconfig.enable = true;
  
  # --- 5. Packages ---
  home.packages = with pkgs; [
    zsh-fzf-tab
    trash-cli
    shellcheck
    shfmt
    zellij
    bottom
    pre-commit
    
    pkgs-unstable.sheldon
    pkgs-unstable.bitwarden-cli
    pkgs-unstable.yazi
    pkgs-unstable.navi
    pkgs-unstable.just
  ];
}
