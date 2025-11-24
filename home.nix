{ config, pkgs, ... }:

{
  # 分割したファイルを読み込む
  imports = [
    ./nix/pkgs.nix
  ];

  # 基本設定
  home.enableNixpkgsReleaseCheck = false;
  
  # ★ここは「Macのログインユーザー名」なので isogaiyuto のままでOK
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";
  
  # クラッシュ回避
  services.kdeconnect.enable = false;

  # フォント設定
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  # シェル設定
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = "source ~/dotfiles/zsh/.zshrc";
    envExtra = "export PATH=$HOME/.nix-profile/bin:$PATH";
  };

  # Git設定 (★ここを修正しました)
  programs.git = {
    enable = true;
    userName = "isopets";              # GitHubのユーザー名
    userEmail = "jandp.0717@gmail.com"; # メールアドレス
  };

  home.stateVersion = "23.11";
}
