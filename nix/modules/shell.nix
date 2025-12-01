{ config, pkgs, ... }:

{
  # --- 1. Magical History (Atuin) ---
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ]; # 上キーは通常の履歴、Ctrl+RでAtuin起動
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      search_mode = "fuzzy";
      style = "compact";
    };
  };

  # --- 2. Existing Tools ---
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
  
  # --- 3. Extra Packages for Zsh ---
  home.packages = with pkgs; [
    zsh-fzf-tab # タブ補完をFZF化する神ツール
  ];
}