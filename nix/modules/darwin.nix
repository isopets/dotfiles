{ config, pkgs, ... }:

{
  # 🚨 必須: システムのプライマリユーザーを定義 (最新のNix-Darwinで必須)
  # ここを設定することで、yabai や defaults 設定がこのユーザーに適用されます
  users.users.isogaiyuto = {
    name = "isogaiyuto";
    home = "/Users/isogaiyuto";
  };
  
  # 🚨 追加: これがないと "system activation must be run as root" エラーの後にコケます
  # (警告メッセージにあった通り、ここを明示します)
  system.primaryUser = "isogaiyuto";

  # --- 1. System Defaults (macOSの隠し設定) ---
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

  # --- 2. Window Manager (Yabai & skhd) ---
  services.yabai = {
    enable = true;
    enableScriptingAddition = true; 
    config = {
      layout = "bsp";
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
      mouse_follows_focus = "on";
    };
  };

  services.skhd = {
    enable = true;
    skhdConfig = ''
      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east
      shift + alt - h : yabai -m window --swap west
      shift + alt - j : yabai -m window --swap south
      shift + alt - k : yabai -m window --swap north
      shift + alt - l : yabai -m window --swap east
      alt - space : yabai -m window --toggle float
      alt - return : open -a "Terminal"
    '';
  };

  # --- 3. Nix Core ---
  # ❌ 削除: services.nix-daemon.enable = true; (廃止されたため削除)
  
  # Nix設定の有効化
  nix.enable = true;
  
  # 実験的機能の有効化 (Flakesに必須)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = 5;
}