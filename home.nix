{ config, pkgs, ... }:
{
  # 基本設定
  home.enableNixpkgsReleaseCheck = false;
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";

  # クラッシュ回避
  services.kdeconnect.enable = false;

  # パッケージリスト
  home.packages = with pkgs; [
    eza bat lazygit fzf direnv jq snyk gnupg mise
  ];

  # Zsh設定
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = "source ~/dotfiles/zsh/.zshrc"; 
  };
  
  programs.git.enable = true;
  
  # バージョンロック
  home.stateVersion = "23.11";
}
