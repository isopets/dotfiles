{ config, pkgs, ... }:

{
  home.enableNixpkgsReleaseCheck = false;
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";

  # ★ここを削除しました (もう手動退避するので不要)
  # home.backupFileExtension = "backup";

  services.kdeconnect.enable = false;
  
  home.packages = with pkgs; [
    eza bat lazygit fzf direnv starship mise
    jq gnused ripgrep fd gnupg
    snyk trivy gum
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  fonts.fontconfig.enable = true;

  # Starship設定 (外部ファイル)
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./config/starship.toml;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = "source ~/dotfiles/zsh/.zshrc";
    envExtra = "export PATH=$HOME/.nix-profile/bin:$PATH";
  };

  programs.git.enable = true;
  home.stateVersion = "24.05";
}
