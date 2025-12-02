{ config, pkgs, ... }:

{
  # 【追記する設定】非自由パッケージ (VS Codeなど) の利用を許可
  nixpkgs.config.allowUnfree = true;
 
 # 既存の imports を拡張し、全てのモジュールを含める
  imports = [ 
    ./nix/pkgs.nix
    ./nix/modules/core.nix
    ./nix/modules/shell.nix
    ./nix/modules/zsh.nix
    ./nix/modules/vscode.nix
    ./nix/modules/neovim.nix
  ];

  # ★ここを削除しました (もう手動退避するので不要)
  # home.backupFileExtension = "backup";

  services.kdeconnect.enable = false;
  
  home.stateVersion = "24.05";
}