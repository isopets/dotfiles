{ config, pkgs, ... }:

{
  # 1. パッケージのインストール (コマンド自体は使えるようにしておく)
  home.packages = [
    pkgs.yabai
    pkgs.skhd
  ];

  # 2. 設定ファイルの生成 (.yabairc)
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
      
      # 除外アプリ
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Raycast$" manage=off
      echo "✅ Yabai config loaded."
    '';
  };

  # 3. キーバインド設定 (.skhdrc)
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
      
      # 固定バイナリを使って再起動
      shift + alt - r : launchctl kickstart -k gui/${toString config.home.uid}/org.nixos.yabai
  '';

  # 4. サービスの定義 (固定バイナリを起動する)
  
  launchd.agents.yabai = {
    enable = true;
    config = {
      # 🚨 ここが重要: Nixのパスではなく、固定パスを指定
      ProgramArguments = [ "/usr/local/bin/yabai-signed" ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardErrorPath = "/tmp/yabai.err";
      StandardOutPath = "/tmp/yabai.out";
      EnvironmentVariables = {
        PATH = "${pkgs.yabai}/bin:${config.home.profileDirectory}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
    };
  };

  launchd.agents.skhd = {
    enable = true;
    config = {
      # 🚨 ここも固定パス
      ProgramArguments = [ "/usr/local/bin/skhd-signed" ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardErrorPath = "/tmp/skhd.err";
      StandardOutPath = "/tmp/skhd.out";
      EnvironmentVariables = {
        PATH = "${pkgs.skhd}/bin:${config.home.profileDirectory}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
    };
  };
}