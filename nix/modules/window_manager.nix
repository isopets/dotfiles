{ pkgs, ... }:

{
  # =========================================================
  # 🎨 Active Borders (JankyBorders)
  # =========================================================
  services.jankyborders = {
    enable = true;
    # アクティブ: 青紫系 (視認性重視), 非アクティブ: 透明
    active_color = "0xff7c4dff"; 
    inactive_color = "0x00000000";
    width = 6.0;
    hidpi = true;
    order = "above";
    style = "round";
  };

  services.aerospace = {
    enable = true;
    settings = {
      # =========================================================
      # 📐 Gaps (見た目の余白)
      # =========================================================
      gaps = {
        inner.horizontal = 10;
        inner.vertical   = 10;
        outer.left       = 10;
        outer.bottom     = 10;
        outer.top        = 10;
        outer.right      = 10;
      };

      # =========================================================
      # 🚦 Window Rules (自動振り分け & フローティング)
      # =========================================================
      on-window-detected = [
        # --- Floating Apps (タイル化しない) ---
        { "if".app-id = "com.apple.finder"; run = "layout floating"; }
        { "if".app-id = "com.apple.systempreferences"; run = "layout floating"; }
        { "if".app-id = "com.apple.calculator"; run = "layout floating"; }
        { "if".app-id = "com.apple.archiveutility"; run = "layout floating"; }
        { "if".app-id = "com.raycast.macos"; run = "layout floating"; }
        { "if".app-id = "com.1password.1password"; run = "layout floating"; }

        # --- Smart Routing (アプリを固定住所へ) ---
        # [W] Web Area
        { "if".app-id = "com.google.Chrome"; run = "move-node-to-workspace 'W-Web 🌐'"; }
        { "if".app-id = "company.thebrowser.Browser"; run = "move-node-to-workspace 'W-Web 🌐'"; }
        
        # [D] Dev Area
        { "if".app-id = "com.microsoft.VSCode"; run = "move-node-to-workspace 'D-Dev 💻'"; }
        { "if".app-id = "org.alacritty"; run = "move-node-to-workspace 'D-Dev 💻'"; }
        { "if".app-id = "com.google.android.studio"; run = "move-node-to-workspace 'D-Dev 💻'"; }
        
        # [C] Chat Area
        { "if".app-id = "com.tinyspeck.slackmacgap"; run = "move-node-to-workspace 'C-Chat 💬'"; }
        { "if".app-id = "com.hnc.Discord"; run = "move-node-to-workspace 'C-Chat 💬'"; }
        { "if".app-id = "jp.naver.line.mac"; run = "move-node-to-workspace 'C-Chat 💬'"; }
        
        # [M] Media Area
        { "if".app-id = "com.spotify.client"; run = "move-node-to-workspace 'M-Media 🎵'"; }
      ];

      # =========================================================
      # ⌨️ Keybindings (Alt = Option)
      # =========================================================
      mode.main.binding = {
        # --- 🚀 App-Centric Navigation (頭文字移動) ---
        alt-w = "workspace 'W-Web 🌐'";
        alt-d = "workspace 'D-Dev 💻'";
        alt-c = "workspace 'C-Chat 💬'";
        alt-m = "workspace 'M-Media 🎵'";
        
        # --- 🪄 The Summoner (アプリを現在地へ呼ぶ) ---
        alt-shift-w = "move-node-to-workspace 'W-Web 🌐'";
        alt-shift-d = "move-node-to-workspace 'D-Dev 💻'";
        alt-shift-c = "move-node-to-workspace 'C-Chat 💬'";
        alt-shift-m = "move-node-to-workspace 'M-Media 🎵'";

        # --- ❓ Cheat HUD (カンニングペーパー) ---
        # Zellijのフローティング機能でヘルプを表示
        alt-slash = "exec-and-forget zellij run --name '⌨️ Shortcuts' --floating --width 60% --height 60% -- bash -c 'cat ~/dotfiles/cheats/aerospace.txt && read'";

        # --- Standard Operations ---
        alt-enter = "exec-and-forget open -n -a Alacritty";
        alt-q = "close";
        
        # --- Layout & Focus ---
        alt-s = "layout accordion";               # Stack Mode (全集中)
        alt-t = "layout tiles horizontal vertical"; # Tile Mode (分割)
        alt-f = "layout floating toggle";         # Float Toggle
        alt-z = "fullscreen";                     # Zoom / Fullscreen (Alt+MはMediaに使ったためZに変更)
        alt-b = "balance-sizes";                  # Balance (整頓)
        alt-tab = "focus-back-and-forth";         # Previous Window

        # --- Vim Focus ---
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";
        
        # --- Vim Move ---
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";
        
        # --- Resize Mode ---
        alt-r = "mode resize";
      };
      
      mode.resize.binding = {
        h = "resize width -50";
        j = "resize height +50";
        k = "resize height -50";
        l = "resize width +50";
        b = "balance-sizes";
        enter = "mode main";
        esc = "mode main";
      };
    };
  };
}
