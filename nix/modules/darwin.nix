{ config, pkgs, ... }:

{
  users.users.isogaiyuto = {
    name = "isogaiyuto";
    home = "/Users/isogaiyuto";
  };
  
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
    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };

  # --- 2. Homebrew Integration ---
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # 記述にないアプリを削除する強力な設定
      upgrade = true;
    };
    taps = [ "nikitabobko/tap" ];
    
    # 🚨 修正: htop をここから削除しました
    casks = [ 
      "aerospace"
      "alacritty"
      "font-hackgen-nerd"
      "xbar"
      "karabiner-elements"
      # "htop" <- これがエラーの原因でした
    ];
  };

  # --- 3. Nix Core ---
  nix.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  nix.settings.auto-optimise-store = false;
  nix.optimise.automatic = true;
  
  system.stateVersion = 5;
}
