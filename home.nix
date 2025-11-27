{ config, pkgs, ... }:

{
  # --- Imports ---
  imports = [
    ./nix/pkgs.nix  # パッケージリストを読み込む
  ];

  # --- Basic Configuration ---
  home.enableNixpkgsReleaseCheck = false;
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";
  
  # 衝突時の自動バックアップ (24.05で有効)
  home.backupFileExtension = "backup";

  # macOSでのクラッシュ回避
  services.kdeconnect.enable = false;

  # --- Font Configuration ---
  fonts.fontconfig.enable = true;

  # --- Starship Configuration ---
  # 設定は ./config/starship.toml に記述し、リンクを貼る
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./config/starship.toml;

  # --- Zsh Configuration ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    # Dotfilesの .zshrc を読み込む
    initExtra = ''
      source ~/dotfiles/zsh/.zshrc
    '';
    
    # Nixのパスを優先的に通す
    envExtra = ''
      export PATH=$HOME/.nix-profile/bin:$PATH
    '';
  };

  # --- Git Configuration ---
  programs.git = {
    enable = true;
    userName = "isopets";
    userEmail = "jandp.0717@gmail.com";
    
    # 便利なエイリアスや設定があればここに追加可能
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "code --wait";
    };
  };

  # --- Version Lock ---
  home.stateVersion = "24.05";
}
