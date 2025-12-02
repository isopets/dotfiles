{ pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    # --- Nix Support ---
    nh
    nixfmt-rfc-style
    
    # --- Core Tools ---
    eza           # ls replacement
    bat           # cat replacement
    zoxide        # cd replacement
    fzf           # Fuzzy finder
    lazygit       # Git TUI
    direnv        # Environment switcher
    starship      # Prompt
    mise          # Language manager
    
    # --- Cockpit Extensions (Modern Tools) ---
    gh            # GitHub CLI
    glow          # Markdown Viewer
    
    # 🚨 Unstable から取得 (Stableにはまだないため)
    pkgs-unstable.jless  # JSON Viewer
    pkgs-unstable.serpl  # Safe Search & Replace

    # --- Utilities ---
    jq            # JSON processor
    gnused        # GNU sed
    ripgrep       # Fast grep
    fd            # Fast find
    gnupg         # GPG
    
    # --- AI & Security ---
    snyk          # Security scanner
    trivy         # Vulnerability scanner
    gum           # UI Library for scripts
    
    # --- Python/Dev ---
    uv            # Python tool manager

    # --- Fonts ---
    (nerdfonts.override { fonts = [ "Hack" ]; })
    yq
    colima # Container Runtime
    docker # CLI Tool
  ];
}
