{ config, pkgs, ... }:

{
  # Zshの設定
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = "source ~/dotfiles/zsh/.zshrc";
    envExtra = "export PATH=$HOME/.nix-profile/bin:$PATH";
  };

  # Gitの設定
  programs.git.enable = true;

  # Starship設定 (外部ファイル)
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ../../config/starship.toml;
  
  # フォント設定
  fonts.fontconfig.enable = true;
}