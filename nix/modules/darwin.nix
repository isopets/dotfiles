{ config, pkgs, ... }:

{
  users.users.isogaiyuto = {
    name = "isogaiyuto";
    home = "/Users/isogaiyuto";
  };
  
  system.primaryUser = "isogaiyuto";

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

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; 
      upgrade = true;
    };
    taps = [ "nikitabobko/tap" ];
    casks = [ "aerospace" ];
  };

  nix.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Auto Optimise
  nix.optimise.automatic = true;
  system.stateVersion = 5;
}
