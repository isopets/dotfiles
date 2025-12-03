{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    # --- Nix Support ---
    nh
    nixfmt-rfc-style
    
    # --- Core Tools ---
    eza
    bat
    zoxide
    fzf
    lazygit
    direnv
    starship
    mise
    
    # --- Cockpit Extensions ---
    gh
    glow
    
    # Unstable Tools
    pkgs-unstable.jless
    pkgs-unstable.serpl

    # --- Utilities ---
    jq
    gnused
    ripgrep
    fd
    gnupg
    
    # --- AI & Security ---
    snyk
    trivy
    gum
    
    # --- Python/Dev ---
   # uv

    # --- Fonts (Modernized) ---
    # 🚨 修正: 古い nerdfonts を削除し、新しい nerd-fonts セットを使用
    nerd-fonts.hack
    
    yq
  ];
}
