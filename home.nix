{ config, pkgs, ... }:

{
  # バージョン不一致警告を無視
  home.enableNixpkgsReleaseCheck = false;
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";

  # ★自動バックアップ設定を削除 (これがエラー原因)
  # home.backupFileExtension = "backup";

  # クラッシュ回避
  services.kdeconnect.enable = false;

  # パッケージリスト
  home.packages = with pkgs; [
    eza bat lazygit fzf direnv starship mise
    jq gnused ripgrep fd gnupg
    snyk trivy
    (nerdfonts.override { fonts = [ "Hack" ]; })
    gum
  ];

  # Zsh設定
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = "source ~/dotfiles/zsh/.zshrc";
    envExtra = "export PATH=$HOME/.nix-profile/bin:$PATH";
  };

  programs.git.enable = true;
  
  # バージョンロック
  home.stateVersion = "24.05";
}
