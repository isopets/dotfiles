{ config, pkgs, ... }:

{
  imports = [ 
    ./nix/pkgs.nix
    ./nix/modules/shell.nix
    ./nix/modules/zsh.nix
    ./nix/modules/vscode.nix
    ./nix/modules/neovim.nix
    ./nix/modules/aerospace.nix
  ];

  home.stateVersion = "24.05";
}
