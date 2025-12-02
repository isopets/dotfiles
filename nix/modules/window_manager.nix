{ config, pkgs, ... }:

{
  # --- 1. The Tiling Window Manager (Yabai) ---
  services.yabai = {
    enable = true;
    enableScriptingAddition = false; # SIP無効化が不要なモード (安全重視)
    config = {
      # レイアウト設定
      layout = "bsp";       # 自動タイル配置
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
      
      # 視覚効果
      active_window_opacity = 1.0;
      normal_window_opacity = 0.9; # 非アクティブを少し薄くする
      
      # マウス操作
      mouse_follows_focus = "on";
      focus_follows_mouse = "autoraise"; # マウス移動だけでフォーカス (好みでoff)
    };
    
    # 除外アプリ (タイル化させたくないもの)
    extraConfig = ''
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Raycast$" manage=off
      yabai -m rule --add app="^Finder$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off
    '';
  };

  # --- 2. The Hotkey Daemon (skhd) ---
  services.skhd = {
    enable = true;
    # キーバインド設定 (Zellijと被らないように Alt/Option キーを使用)
    skhdConfig = ''
      # --- Window Focus (移動) ---
      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east

      # --- Window Move (入替) ---
      shift + alt - h : yabai -m window --swap west
      shift + alt - j : yabai -m window --swap south
      shift + alt - k : yabai -m window --swap north
      shift + alt - l : yabai -m window --swap east

      # --- Window Resize (サイズ変更) ---
      ctrl + alt - h : yabai -m window --resize left:-20:0
      ctrl + alt - j : yabai -m window --resize bottom:0:20
      ctrl + alt - k : yabai -m window --resize top:0:-20
      ctrl + alt - l : yabai -m window --resize right:20:0

      # --- Layout Toggle ---
      alt - f : yabai -m window --toggle zoom-fullscreen
      alt - space : yabai -m window --toggle float

      # --- App Launch (Optional) ---
      alt - return : open -a "Alacritty" # または "Terminal"
    '';
  };
}
