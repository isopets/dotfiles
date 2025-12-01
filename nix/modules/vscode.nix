{ config, pkgs, ... }:

{
  programs.vscode.enable = true;

  # VS Code のグローバル設定 (User Settings)
  # 注意: Nix言語なのでコメントは '#'、代入は '=' を使用します
  programs.vscode.userSettings = {
    # --- Terminal Integration ---
    # Shell Integrationを無効化 (Zshの純粋な動作を保証)
    "terminal.integrated.shellIntegration.enabled" = false;
    
    # ヘルパーツールの自動インストールによるパスワード要求を防止
    "terminal.integrated.sendKeybindingsToShell" = true;
    "terminal.integrated.confirmOnExit" = "never";
    
    # --- Update Behavior ---
    # 自動アップデートを抑制
    "update.mode" = "manual";
    "extensions.autoUpdate" = false;

    # --- Git Automation ---
    # Git機能は有効化するが、親フォルダの自動スキャン通知は抑制
    "git.enabled" = true;
    "git.detectors" = [];
    "git.autofetch" = false;
    "git.openRepositoryInParentFolders" = "never";

    # Gitリポジトリ検出時、Source Controlパネルを自動で開く (アンテナ機能)
    "scm.autoReveal" = true;
  };
}
