{ config, pkgs, ... }:

{
  # ----------------------------------------------------
  # 基本設定とHome Managerのバージョンロック
  # ----------------------------------------------------
  home.enableNixpkgsReleaseCheck = false; # バージョン不一致警告を無視
  
  # ユーザー情報
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";

  # ----------------------------------------------------
  # サービスの無効化 (クラッシュ原因の回避)
  # ----------------------------------------------------
  # 致命的なクラッシュを引き起こすLinux向けサービスを明示的に無効化
  services.kdeconnect.enable = false;
  
  # ----------------------------------------------------
  # 1. パッケージリスト (CLIツールの移行先)
  # ----------------------------------------------------
  home.packages = with pkgs; [
    eza         # ls 代替
    bat         # cat 代替
    lazygit
    fzf
    direnv      # 環境変数管理
    jq          # JSON処理
    snyk        # セキュリティ
    gnupg       # GPG
    mise        # 言語バージョン管理
  ];

  # 2. Zshの設定 (Home Managerに管理を移譲)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # 既存のZsh資産の読み込み (Nix管理が完了したらこの行は削除)
    initExtra = "source ~/.zshrc"; 
  };
  
  # 3. Gitの設定
  programs.git.enable = true;

  # 4. Home Managerのバージョンをロック
  home.stateVersion = "24.05"; 
}
