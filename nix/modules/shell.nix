{ config, pkgs, ... }:

{
  # --- Tools & Integrations ---
  # ※ Zsh本体の設定は zsh.nix に移動済み

  # Direnv (環境切り替え)
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Mise (言語バージョン管理)
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };
  
  # Zoxide (高速移動)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = ["--cmd cd"];
  };

  # Git
  programs.git = {
    enable = true;
    userName = "isopets";
    userEmail = "jandp.0717@gmail.com";
  };

  # Starship (プロンプト)
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ../../config/starship.toml;

  # Fonts
  fonts.fontconfig.enable = true;
}
