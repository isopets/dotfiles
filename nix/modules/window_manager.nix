{ pkgs, ... }:

{
  # =========================================================
  # 🎨 Active Borders (視認性向上)
  # =========================================================
  services.jankyborders = {
    enable = true;
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
      # 🌅 The Morning Routine (始業ランチャー)
      # =========================================================
      # 起動時にインタラクティブなランチャーを立ち上げる
      after-startup-command = [
        "exec-and-forget open -a Alacritty --args -e ~/dotfiles/scripts/cockpit-launcher.sh"
      ];

      # =========================================================
      # 🖱️ Magnet Mouse (直感性の確保)
      # =========================================================
      # フォーカス移動に合わせてマウスカーソルも追従させる
      on-focused-monitor-changed = ["move-mouse monitor-lazy-center"];
      on-focus-changed = ["move-mouse window-lazy-center"];

      # =========================================================
      # 📐 Gaps (初期設定)
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
      # 🚦 Window Rules (自動整理 & 救助)
      # =========================================================
      on-window-detected = [
        # --- 🛡️ Smart Floaters (設定画面などは浮かして救出) ---
        {
          "if".window-title-regex-substring = "(Settings|Preferences|设置|設定|環境設定|Library|Info|Inspector)";
          run = "layout floating";
        }
        {
          "if".window-title-regex-substring = "^(Open|Save|Select|Upload|Choose)";
          run = "layout floating";
        }
        {
          "if".window-title-regex-substring = "Picture-in-Picture";
          run = "layout floating";
        }

        # --- Standard Floaters ---
        { "if".app-id = "com.apple.finder"; run = "layout floating"; }
        { "if".app-id = "com.apple.systempreferences"; run = "layout floating"; }
        { "if".app-id = "com.apple.calculator"; run = "layout floating"; }
        { "if".app-id = "com.1password.1password"; run = "layout floating"; }
        { "if".app-id = "com.raycast.macos"; run = "layout floating"; }

        # --- Smart Routing (アプリの住所固定) ---
        # [W] Web
        { "if".app-id = "com.google.Chrome"; run = "move-node-to-workspace 'W-Web 🌐'"; }
        { "if".app-id = "company.thebrowser.Browser"; run = "move-node-to-workspace 'W-Web 🌐'"; }
        
        # [D] Dev
        { "if".app-id = "com.microsoft.VSCode"; run = "move-node-to-workspace 'D-Dev 💻'"; }
        { "if".app-id = "org.alacritty"; run = "move-node-to-workspace 'D-Dev 💻'"; }
        
        # [C] Chat
        { "if".app-id = "com.tinyspeck.slackmacgap"; run = "move-node-to-workspace 'C-Chat 💬'"; }
        { "if".app-id = "com.hnc.Discord"; run = "move-node-to-workspace 'C-Chat 💬'"; }
        
        # [M] Media
        { "if".app-id = "com.spotify.client"; run = "move-node-to-workspace 'M-Media 🎵'"; }
      ];

      # =========================================================
      # ⌨️ Main Mode bindings
      # =========================================================
      mode.main.binding = {
        # 🦸 God Mode (Service Mode) への入り口
        alt-semicolon = "mode service";

        # 🧭 Navigation (App-Centric)
        alt-w = "workspace 'W-Web 🌐'";
        alt-d = "workspace 'D-Dev 💻'";
        alt-c = "workspace 'C-Chat 💬'";
        alt-m = "workspace 'M-Media 🎵'";
        
        # 🔄 Context Recall (直前のワークスペースへ)
        alt-backslash = "workspace-back-and-forth"; 
        
        # 📡 Rescue Radar (行方不明のウィンドウを探す - Mission Control)
        alt-e = "exec-and-forget open -a 'Mission Control'";

        # 🪄 Summon (アプリを現在地へ呼ぶ)
        alt-shift-w = "move-node-to-workspace 'W-Web 🌐'";
        alt-shift-d = "move-node-to-workspace 'D-Dev 💻'";
        alt-shift-c = "move-node-to-workspace 'C-Chat 💬'";
        alt-shift-m = "move-node-to-workspace 'M-Media 🎵'";

        # ❓ Cheat HUD (カンニングペーパー)
        alt-slash = "exec-and-forget zellij run --name '⌨️ Shortcuts' --floating --width 60% --height 60% -- bash -c 'cat ~/dotfiles/cheats/aerospace.txt && read'";

        # ⚙️ Standard Actions
        alt-enter = "exec-and-forget open -n -a Alacritty";
        alt-q = "close";
        
        # 📐 Layouts
        alt-s = "layout accordion";               # Stack (全集中)
        alt-t = "layout tiles horizontal vertical"; # Tile (分割)
        alt-f = "layout floating toggle";         # Float (浮遊)
        alt-z = "fullscreen";                     # Zoom (最大化)
        alt-b = "balance-sizes";                  # Balance (整頓)
        alt-tab = "focus-back-and-forth";         # Previous Window

        # 🎮 Vim Focus
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";
        
        # 🎮 Vim Move
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";
        
        # Resize Mode
        alt-r = "mode resize";
      };

      # =========================================================
      # 🦸 God Mode (Service Mode) - 指一本で支配する
      # =========================================================
      mode.service.binding = {
        esc = "mode main";
        enter = "mode main";
        alt-semicolon = "mode main";

        # Move Window (HJKL)
        h = "move left";
        j = "move down";
        k = "move up";
        l = "move right";

        # Move to Monitor (Shift + HL)
        shift-h = "move-node-to-monitor left";
        shift-l = "move-node-to-monitor right";

        # Throw to Workspace (One Key)
        w = ["move-node-to-workspace 'W-Web 🌐'" "mode main"];
        d = ["move-node-to-workspace 'D-Dev 💻'" "mode main"];
        c = ["move-node-to-workspace 'C-Chat 💬'" "mode main"];
        m = ["move-node-to-workspace 'M-Media 🎵'" "mode main"];

        # Hardware Control (Volume)
        minus = ["exec-and-forget osascript -e 'set volume output volume (output volume of (get volume settings) - 5)'"];
        equal = ["exec-and-forget osascript -e 'set volume output volume (output volume of (get volume settings) + 5)'"];
        0     = ["exec-and-forget osascript -e 'set volume output muted not (output muted of (get volume settings))'" "mode main"];

        # Layout Actions
        f = ["layout floating toggle" "mode main"];
        s = ["layout accordion" "mode main"];
        t = ["layout tiles horizontal vertical" "mode main"];
        backspace = ["close" "mode main"];
        r = "mode resize";
        
        # 🎬 Cinema Mode (Gaps Toggle)
        g = ["config gaps.inner.horizontal 0" "config gaps.inner.vertical 0" "config gaps.outer.top 0" "config gaps.outer.bottom 0" "config gaps.outer.left 0" "config gaps.outer.right 0" "mode main"];
        shift-g = ["config gaps.inner.horizontal 10" "config gaps.inner.vertical 10" "config gaps.outer.top 10" "config gaps.outer.bottom 10" "config gaps.outer.left 10" "config gaps.outer.right 10" "mode main"];
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
