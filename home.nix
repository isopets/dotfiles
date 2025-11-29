{ config, pkgs, ... }:

{
  # 既存の pkgs.nix をインポート (パッケージリストの定義)
  imports = [ ./nix/pkgs.nix ];

  # 全てのモジュールをインポート (設定の上書き、結合)
  modules = [
  ./nix/modules/core.nix
  ./nix/modules/shell.nix
  ./nix/modules/vscode.nix
  ./nix/modules/vscode/profiles.nix
  ];

  # ★ここを削除しました (もう手動退避するので不要)
  # home.backupFileExtension = "backup";

  services.kdeconnect.enable = false;
  
  home.stateVersion = "24.05";
}