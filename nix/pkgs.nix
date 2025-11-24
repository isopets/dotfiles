{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Core
    eza
    bat
    lazygit
    fzf
    direnv
    starship
    mise
    
    # Utilities
    jq
    gnused
    ripgrep
    fd
    gnupg
    
    # Security
    snyk
    trivy

    # Fonts
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];
}
