{ config, pkgs, ... }:

{
  # --- 1. The Tiling Window Manager (Yabai) ---
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

  # --- 2. The Hotkey Daemon (skhd) ---
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
}