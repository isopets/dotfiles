{ config, pkgs, ... }:

{
  # --- 1. Magical History (Atuin) ---
  # 以前使っていた「履歴同期」機能を復活
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ]; # 上キーは普通の履歴にする
  };

  # --- 2. Fuzzy Finder (FZF) ---
  # これを true にするだけで、Ctrl+R / Ctrl+T が自動設定されます
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" ];
  };

  # --- 3. Directory Navigation (Zoxide) ---
  # 'cd' コマンドを 'z' に置き換える設定
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ]; # cdコマンドをジャックする
  };

  # --- 4. Environment (Direnv) ---
  # フォルダに入った瞬間にPython環境などをロード
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # --- 5. Cheatsheet (Navi) ---
  # Ctrl+G で「使いかた」を検索できる機能
  programs.navi = {
    enable = true;
    enableZshIntegration = true;
  };
  
  # --- 6. Starship (Prompt) ---
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # 設定ファイルは config フォルダから読み込む
  };
  xdg.configFile."starship.toml".source = ../../config/starship.toml;
}
