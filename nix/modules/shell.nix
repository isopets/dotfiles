{ config, pkgs, ... }:

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

  # --- 2. Core Tools & Integrations ---
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

  # --- 3. Git & Delta (Visual Diff) ---
  programs.git = {
    enable = true;
    userName = "isopets";
    userEmail = "jandp.0717@gmail.com";
    
    # Delta: 美しいDiff表示ツール
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

  # --- 4. UI & Fonts ---
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ../../config/starship.toml;
  fonts.fontconfig.enable = true;
  
  # --- 5. Package Bundle ---
  home.packages = with pkgs; [
    # Shell Enhancements
    zsh-fzf-tab   # 視覚的補完
    trash-cli     # 安全な削除
    sheldon       # プラグインマネージャー
    
    # Quality Control
    shellcheck    # シェルスクリプト解析
    shfmt         # シェルスクリプト整形
    
    # Workspace
    zellij        # ターミナルマルチプレクサ
  ];
}
