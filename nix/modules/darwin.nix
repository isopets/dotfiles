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
    # 🚨 追加: .DS_Store 抑制設定
    # (DSDontWriteNetworkStores: ネットワークドライブで作らない)
    # (DSDontWriteUSBStores: USBメモリで作らない)
    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };

  # --- 2. Homebrew Integration (AeroSpace) ---
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # 記述にないアプリ(Yabai等)を削除
      upgrade = true;
    };
    taps = [ "nikitabobko/tap"  ];
    casks = [ "aerospace"  "Alacritty"  "font-hackgen-nerd"  "xbar" ];
  };

  # --- 3. Nix Core ---
  nix.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes"  ];
  
  # Auto Optimise (Darwin)
  nix.settings.auto-optimise-store = false; # Unstableでのクラッシュ防止のためfalse
  nix.optimise.automatic = true;            # 定期実行で最適化
  
  system.stateVersion = 5;
}
