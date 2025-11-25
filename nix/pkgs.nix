{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # --- System Essentials ---
    gnused        # gsed (必須: スクリプトの置換処理用)
    gum           # UI Library (必須: メニュー表示用)
    git
    
    # --- Core Tools ---
    eza           # ls replacement
    bat           # cat replacement
    zoxide        # cd replacement
    fzf           # Fuzzy finder
    lazygit       # Git TUI
    direnv        # Environment switcher
    starship      # Prompt
    mise          # Language manager
    
    # --- Utilities ---
    jq            # JSON processor
    ripgrep       # Fast grep
    fd            # Fast find
    gnupg         # GPG
    
    # --- Security ---
    snyk          # Security scanner
    trivy         # Vulnerability scanner

    # --- Fonts ---
    (nerdfonts.override { fonts = [ "Hack" ]; })
  ];
}
