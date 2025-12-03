{ config, pkgs, ... }:

{
  # --- 1. Install AeroSpace (via Homebrew Cask) ---
  # Nixpkgsにまだないため、DarwinのBrew連携機能を使用
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # 記述されていないアプリは削除する（強力な管理）
    };
    casks = [
      "nikitabobko/tap/aerospace"
    ];
  };

  # --- 2. Configure AeroSpace (TOML) ---
  # 設定ファイルはホームディレクトリに配置
  home.file.".config/aerospace/aerospace.toml".text = ''
    # ✈️ AeroSpace Config (i3-like Keybindings)

    # Start automatically
    after-login-command = []

    # Normalizations
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

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
    
    # 1. Focus (移動) - Vim Style
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    # 2. Move (入替)
    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    # 3. Resize (リサイズモードへ)
    alt-r = 'mode resize'

    # 4. Workspace (1-9)
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    
    # 5. Layout
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'
    
    # 6. System
    alt-enter = 'exec-and-forget open -a Terminal'

    # --- Resize Mode ---
    [mode.resize.binding]
    h = 'resize width -50'
    j = 'resize height +50'
    k = 'resize height -50'
    l = 'resize width +50'
    enter = 'mode main'
    esc = 'mode main'
  '';
}