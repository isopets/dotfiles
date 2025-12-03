{ config, pkgs, ... }:

{
  # --- 1. Install AeroSpace (via Homebrew Cask) ---
  homebrew = {
    enable = true;
    
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # 記述されていないアプリは削除 (強力な同期)
      upgrade = true;
    };
    
    # Tap (リポジトリ) の登録
    taps = [
      "nikitabobko/tap"
    ];
    
    # Cask (アプリ) のインストール
    casks = [
      "aerospace"
    ];
  };

  # --- 2. Configure AeroSpace (TOML) ---
  # 設定ファイルをホームディレクトリに生成
  home.file.".config/aerospace/aerospace.toml".text = ''
    # ✈️ AeroSpace Config (Cockpit Style)

    # Start automatically
    after-login-command = []

    # Gaps (見た目の余白)
    [gaps]
    inner.horizontal = 10
    inner.vertical =   10
    outer.left =       10
    outer.bottom =     10
    outer.top =        10
    outer.right =      10

    # Keybindings (Alt = Option)
    [mode.main.binding]
    
    # Focus (移動) - Vim Style
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    # Move (入替)
    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    # Resize
    alt-r = 'mode resize'

    # Workspaces
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    
    # Layout
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'
    
    # System
    alt-enter = 'exec-and-forget open -a Terminal'

    # Resize Mode
    [mode.resize.binding]
    h = 'resize width -50'
    j = 'resize height +50'
    k = 'resize height -50'
    l = 'resize width +50'
    enter = 'mode main'
    esc = 'mode main'
  '';
}
