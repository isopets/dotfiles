{ config, pkgs, ... }:

{
  # --- 1. System Defaults (macOSの隠し設定) ---
  system.defaults = {
    # Dockの設定
    dock = {
      autohide = true;           # 自動的に隠す
      show-recents = false;      # 最近使ったアプリを表示しない
      mru-spaces = false;        # 操作スペースを勝手に並べ替えない (Yabaiに必須)
    };
    
    # Finderの設定
    finder = {
      AppleShowAllExtensions = true; # 拡張子を常に表示
      FXPreferredViewStyle = "clmv"; # カラムビューをデフォルトに
      _FXShowPosixPathInTitle = true; # タイトルバーにパスを表示
    };
    
    # トラックパッドとキーボード
    NSGlobalDomain = {
      "com.apple.trackpad.scaling" = 3.0; # 軌跡の速さ
      KeyRepeat = 2;  # キーリピート速度 (速い)
      InitialKeyRepeat = 15;
    };
  };

  # --- 2. Window Manager (Yabai & skhd as Services) ---
  # Nix-Darwinなら "services" として安定稼働させられる
  services.yabai = {
    enable = true;
    enableScriptingAddition = true; # SIP無効化環境ならTrue、そうでなければFalse
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
      # Focus Window
      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east
      
      # Swap Window
      shift + alt - h : yabai -m window --swap west
      shift + alt - j : yabai -m window --swap south
      shift + alt - k : yabai -m window --swap north
      shift + alt - l : yabai -m window --swap east
      
      # Toggle Float
      alt - space : yabai -m window --toggle float
      
      # Launch Terminal
      alt - return : open -a "Terminal"
    '';
  };

  # --- 3. Nix-Darwin Core ---
  # 必須設定: Nixデーモンの管理を有効化
  services.nix-daemon.enable = true;
  # 必須設定: この設定が適用された時点のState Version
  system.stateVersion = 5;
}
