{ config, pkgs, pkgs-unstable, ... }:

{
  # =================================================================
  # 🕹️ Cockpit Shell Infrastructure
  # =================================================================

  # --- 1. Magical History (Atuin) ---
  # 過去の全コマンド履歴をデータベース化し、Ctrl+R で瞬時に検索可能にする
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

  # --- 2. Core Integrations (Environment & Navigation) ---
  
  # Direnv: ディレクトリごとの環境変数自動ロード
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Mise: 言語バージョン管理 (Node, Python, Go etc.)
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };
  
  # Zoxide: 賢い 'cd' コマンド (移動履歴を学習しテレポート)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"]; # cd コマンドを完全に置き換える
  };

  # --- 3. Git & Delta (Visual Diff) ---
  programs.git = {
    enable = true;
    userName = "isopets";
    userEmail = "jandp.0717@gmail.com";
    
    # Delta: Gitの差分をGitHubのように美しく表示
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
  
  # --- 5. Package Bundle (The Toolkit) ---
  home.packages = with pkgs; [
    # Shell Enhancements
    zsh-fzf-tab   # 視覚的補完 (TabでFZFメニューが開く)
    trash-cli     # 安全な削除 (rm の代わり)
    
    # Quality Control & Automation
    shellcheck    # シェルスクリプト静的解析
    shfmt         # シェルスクリプト整形
    pre-commit    # コミット前の自動チェックフレームワーク
    nvd           # アップデート時のバージョン差分可視化
    
    # Workspace & Monitor
    zellij        # ターミナルマルチプレクサ (不死身のセッション)
    bottom        # システムリソースモニター (btm)

    # --- Containerization (Docker without Desktop) ---
    colima  # The Container Runtime
    docker  # The CLI Tool
    
    # --- Bleeding Edge Tools (From Unstable Channel) ---
    # 最新機能を使うため、意図的にUnstableチャンネルから導入
    
    pkgs-unstable.sheldon       # 高速Zshプラグインマネージャー
    pkgs-unstable.bitwarden-cli # パスワード管理 (最新セキュリティパッチ)
    pkgs-unstable.yazi          # ターミナルファイラー (画像プレビュー対応)
    pkgs-unstable.navi          # 対話型チートシート
    pkgs-unstable.just          # タスクランナー (The Universal Commander)
    pkgs-unstable.yabai
    pkgs-unstable.skhd
  ];
}
