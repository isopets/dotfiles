{ config, pkgs, ... }:

let
  # ラッパーアプリ内の実行スクリプトを直接指定
  yabaiScript = "${config.home.homeDirectory}/Applications/yabai-wrapper.app/Contents/MacOS/yabai-wrapper";
  skhdScript = "${config.home.homeDirectory}/Applications/skhd-wrapper.app/Contents/MacOS/skhd-wrapper";
in
{
  home.packages = [ pkgs.yabai pkgs.skhd ];

  # .yabairc (設定)
  home.file.".yabairc" = {
    executable = true;
    text = ''
      #!/usr/bin/env sh
      yabai -m config layout bsp
      yabai -m config top_padding 10
      yabai -m config bottom_padding 10
      yabai -m config left_padding 10
      yabai -m config right_padding 10
      yabai -m config window_gap 10
      yabai -m config mouse_follows_focus on
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Raycast$" manage=off
      echo "✅ Yabai config loaded."
    '';
  };

  # .skhdrc (キーバインド)
  home.file.".skhdrc".text = ''
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
      shift + alt - r : launchctl kickstart -k gui/${toString config.home.uid}/org.nixos.yabai
  '';

  # サービス定義 (ラッパーを起動)
  launchd.agents.yabai = {
    enable = true;
    config = {
      ProgramArguments = [ "${yabaiScript}" ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardErrorPath = "/tmp/yabai.err";
      StandardOutPath = "/tmp/yabai.out";
    };
  };

  launchd.agents.skhd = {
    enable = true;
    config = {
      ProgramArguments = [ "${skhdScript}" ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardErrorPath = "/tmp/skhd.err";
      StandardOutPath = "/tmp/skhd.out";
    };
  };
}
