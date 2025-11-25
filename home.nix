{ config, pkgs, ... }:

{
  home.enableNixpkgsReleaseCheck = false;
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";
  
  home.backupFileExtension = "backup";
  services.kdeconnect.enable = false;

  home.packages = with pkgs; [
    eza bat lazygit fzf direnv mise
    jq gnused ripgrep fd gnupg
    snyk trivy gum
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  fonts.fontconfig.enable = true;

  # --- Starship (外部ファイル読み込み) ---
  programs.starship.enable = true;
  
  # "xdg.configFile" を使うと ~/.config/starship.toml にリンクが貼られます
  xdg.configFile."starship.toml".source = ./config/starship.toml;

  # --- Zsh ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = "source ~/dotfiles/zsh/.zshrc";
    envExtra = "export PATH=$HOME/.nix-profile/bin:$PATH";
  };

  programs.git.enable = true;
  home.stateVersion = "24.05";
}
