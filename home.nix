{ config, pkgs, ... }:
{
  home.enableNixpkgsReleaseCheck = false;
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";
  home.backupFileExtension = "backup";     # ★重要: バックアップ設定
  services.kdeconnect.enable = false;      # ★重要: クラッシュ回避

  home.packages = with pkgs; [
    eza bat lazygit fzf direnv jq snyk gnupg mise
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = "source ~/dotfiles/zsh/.zshrc"; 
  };
  programs.git.enable = true;
  home.stateVersion = "23.11";
}
