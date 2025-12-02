{ pkgs, ... }:

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
    
    # --- Cockpit Extensions (New!) ---
    gh            # GitHub CLI (Control Tower)
    glow          # Markdown Viewer (Document Viewer)
    jless         # JSON Viewer (Data Scope)
    serpl         # Safe Search & Replace (Refactor)

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
  ];
}
