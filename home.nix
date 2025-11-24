{ config, pkgs, ... }:

{
  # ----------------------------------------------------
  # 基本設定
  # ----------------------------------------------------
  home.enableNixpkgsReleaseCheck = false;
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";
  
  # クラッシュ回避
  services.kdeconnect.enable = false;

  # ----------------------------------------------------
  # 1. パッケージリスト (CLIツール)
  # ----------------------------------------------------
  home.packages = with pkgs; [
    # Core
    eza
    bat
    lazygit
    fzf
    direnv
    starship
    mise
    
    # Utilities
    jq
    gnused
    ripgrep
    fd
    gnupg
    
    # Security
    snyk
    trivy
  ];

  # ----------------------------------------------------
  # 2. Zshの設定 (機能の復活と快適化)
  # ----------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    # ここにカスタム設定を記述
    initExtra = ''
      # 1. コメント付きコピペを許可 (エラー回避)
      setopt INTERACTIVE_COMMENTS
      
      # 2. 最強のDotfiles設定を読み込む (devコマンド等の復活)
      if [ -f ~/dotfiles/zsh/.zshrc ]; then
        source ~/dotfiles/zsh/.zshrc
      fi
    '';
  };
  
  # 3. Gitの設定
  programs.git.enable = true;

  # 4. バージョンロック
  home.stateVersion = "23.11"; 
}
