{ config, pkgs, ... }:

{
  programs.vscode.enable = true;

  # VS Code のグローバル設定 (User Settings)
  programs.vscode.userSettings = {
    # 🚨 【最重要】このエラーを消すための設定
    "terminal.integrated.shellIntegration.enabled" = false;
    
    # パスワード要求を消す設定
    "terminal.integrated.sendKeybindingsToShell" = true;
    "terminal.integrated.confirmOnExit" = "never";
    
    # 自動アップデート抑制
    "update.mode" = "manual";
    "extensions.autoUpdate" = false;

    # Git設定
    "git.enabled" = true;
    "git.detectors" = [];
    "git.autofetch" = false;
    "git.openRepositoryInParentFolders" = "never";
    "scm.autoReveal" = true;
  };
}
