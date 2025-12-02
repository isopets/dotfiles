{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    # 🚨 修正: 最新のHome Manager仕様に合わせて profiles.default 配下に記述
    profiles.default.userSettings = {
      # --- Terminal Integration ---
      # Shell Integrationを無効化 (Zshの純粋な動作を保証し、エラーを防ぐ)
      "terminal.integrated.shellIntegration.enabled" = false;
      
      # ヘルパーツールの自動インストールによるパスワード要求を防止
      "terminal.integrated.sendKeybindingsToShell" = true;
      "terminal.integrated.confirmOnExit" = "never";
      
      # --- Update Behavior ---
      # 自動アップデートを抑制 (Nix管理と競合しないようにする)
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
  };
}
