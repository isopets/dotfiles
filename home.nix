{ config, pkgs, ... }:

{
  home.enableNixpkgsReleaseCheck = false;
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";

  # macOSでのクラッシュ回避 (重要)
  services.kdeconnect.enable = false;

  home.packages = with pkgs; [
    eza
    bat
    lazygit
    fzf
    direnv
    jq
    snyk
    gnupg
    mise  # 24.05なら存在します
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = "source ~/.zshrc";
  };

  programs.git.enable = true;

  # バージョンを合わせる
  home.stateVersion = "24.05";
}
