{ config, pkgs, ... }:
{
  home.enableNixpkgsReleaseCheck = false;
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";
  home.backupFileExtension = "backup";
  services.kdeconnect.enable = false;
  home.packages = with pkgs; [
    eza bat lazygit fzf direnv starship mise
    jq gnused ripgrep fd gnupg snyk trivy
    (nerdfonts.override { fonts = [ "Hack" ]; })
    gum
  ];
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;
  programs.zsh.initExtra = "source ~/dotfiles/zsh/.zshrc";
  programs.git.enable = true;
  home.stateVersion = "24.05";
}
