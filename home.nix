{ config, pkgs, ... }:

{
  # バージョン不一致警告を無視
  home.enableNixpkgsReleaseCheck = false;
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";

  # クラッシュ回避
  services.kdeconnect.enable = false;

  # パッケージリスト (miseは24.05で使えるため復活)
  home.packages = with pkgs; [
    eza bat lazygit fzf direnv jq snyk gnupg mise
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  # Zsh設定
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = "source ~/dotfiles/zsh/.zshrc"; 
  };
  
  programs.git.enable = true;

  # バージョンを 24.05 に上げる
  home.stateVersion = "24.05";
}
