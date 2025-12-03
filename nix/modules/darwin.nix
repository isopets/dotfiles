{ config, pkgs, ... }:

{
  users.users.isogaiyuto = {
    name = "isogaiyuto";
    home = "/Users/isogaiyuto";
  };
  nixpkgs.config.allowUnfree = true;
  system.primaryUser = "isogaiyuto";

  # --- 1. System Defaults ---
  system.defaults = {
    dock = {
      autohide = true;
      show-recents = false;
      mru-spaces = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv";
      _FXShowPosixPathInTitle = true;
    };
    NSGlobalDomain = {
      "com.apple.trackpad.scaling" = 3.0;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };
  };

  # --- 2. Homebrew Integration (App Install) ---
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; 
      upgrade = true;
    };
    taps = [
      "nikitabobko/tap"
    ];
    casks = [
      "aerospace"
    ];
  };

  # --- 3. Nix Core ---
  nix.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = 5;
}
