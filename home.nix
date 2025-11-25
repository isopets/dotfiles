{ config, pkgs, ... }:

{
  # バージョン不一致警告を無視
  home.enableNixpkgsReleaseCheck = false;
  home.username = "isogaiyuto";
  home.homeDirectory = "/Users/isogaiyuto";
  
  # ★重要: これを使うために 24.05 が必要
  home.backupFileExtension = "backup";

  # クラッシュ回避
  services.kdeconnect.enable = false;

  # パッケージリスト
  home.packages = with pkgs; [
    eza bat lazygit fzf direnv starship mise
    jq gnused ripgrep fd gnupg
    snyk trivy
    (nerdfonts.override { fonts = [ "Hack" ]; })
    gum
  ];

  # フォント設定
  fonts.fontconfig.enable = true;

  # Zsh設定 (Nixで生成)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    
    # .zshrc の末尾に追加される内容 (コックピット機能の読み込み)
    initExtra = ''
      # --- 1. パス設定 ---
      export PATH="$HOME/.nix-profile/bin:/opt/homebrew/bin:$PATH"
      export GOPATH="$HOME/go"
      export PATH="$GOPATH/bin:$PATH"

      # --- 2. 秘密情報の読み込み ---
      [ -f "$HOME/dotfiles/zsh/.zsh_secrets" ] && source "$HOME/dotfiles/zsh/.zsh_secrets"

      # --- 3. カスタム関数の読み込み ---
      if [ -d "$HOME/dotfiles/zsh/config" ]; then
        for f in "$HOME/dotfiles/zsh/config/"*.zsh; do
          source "$f"
        done
      fi

      # --- 4. 起動時チェック ---
      if command -v show-tip > /dev/null; then
          show-tip
      fi
    '';
  };

  programs.git = {
    enable = true;
    userName = "isopets";
    userEmail = "jandp.0717@gmail.com";
  };

  # ★重要: バージョンを 24.05 に指定
  home.stateVersion = "24.05";
}
