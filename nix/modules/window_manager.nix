{ pkgs, ... }:

{
  services.aerospace = {
    enable = true;
    settings = {
      # =========================================================
      # 🎨 Visuals (Gaps & Padding)
      # =========================================================
      # ウィンドウ間の隙間（美しさと視認性アップ）
      gaps = {
        inner.horizontal = 10;
        inner.vertical   = 10;
        outer.left       = 10;
        outer.bottom     = 10;
        outer.top        = 10;
        outer.right      = 10;
      };

      # =========================================================
      # 🚦 Window Rules (自動フローティング)
      # =========================================================
      # これらはタイル化せず、最初から浮かせます
      on-window-detected = [
        {
          "if".app-id = "com.apple.finder";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.systempreferences";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.calculator";
          run = "layout floating";
        }
        {
          "if".app-id = "com.apple.archiveutility";
          run = "layout floating";
        }
      ];

      # =========================================================
      # ⌨️ Keybindings (Alt = Option)
      # =========================================================
      mode.main.binding = {
        # --- 1. アプリ起動 ---
        alt-enter = "exec-and-forget open -n -a Alacritty";

        # --- 2. フォーカス移動 (Vim風) ---
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        # --- 3. ウィンドウ移動 (Vim風) ---
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        # --- 4. レイアウト切り替え (ここが重要！) ---
        alt-s = "layout accordion";               # Stack (重ねる) モード
        alt-t = "layout tiles horizontal vertical"; # Tile (分割) モード
        alt-f = "layout floating toggle";         # Float (浮遊) トグル

        # --- 5. 分割方向の変更 ---
        alt-slash = "layout tiles horizontal vertical"; # 縦横ローテーション
        alt-comma = "layout accordion horizontal vertical"; # スタック方向変更

        # --- 6. ワークスペース移動 ---
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";

        # --- 7. ワークスペースへ移動 ---
        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";

        # --- 8. その他 ---
        alt-q = "close";         # 閉じる
        alt-r = "mode resize";   # リサイズモードへ
      };

      # =========================================================
      # 📏 Resize Mode
      # =========================================================
      mode.resize.binding = {
        h = "resize width -50";
        j = "resize height +50";
        k = "resize height -50";
        l = "resize width +50";
        enter = "mode main";
        esc = "mode main";
      };
    };
  };
}
