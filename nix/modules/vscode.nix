{ config, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default.userSettings = {
      "terminal.integrated.shellIntegration.enabled" = false;
      "terminal.integrated.sendKeybindingsToShell" = true;
      "terminal.integrated.confirmOnExit" = "never";
      "update.mode" = "manual";
      "extensions.autoUpdate" = false;
      "git.enabled" = true;
      "git.detectors" = [];
      "git.autofetch" = false;
      "git.openRepositoryInParentFolders" = "never";
      "scm.autoReveal" = true;
    };
  };
}
