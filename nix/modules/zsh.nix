{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Nix管理の不変エイリアス
    shellAliases = {
      ls = "eza --icons --git";
      cat = "bat";
      grep = "rg";
      find = "fd";
      vi = "nvim";
      vim = "nvim";
      cp = "cp -i";
      mv = "mv -i";
    };

    # 🚨 修正完了: initExtra -> initContent (最新仕様)
    initContent = ''
      # 1. FZF-Tab Integration
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # 2. Auto-Discovery Loader (ファイル名に依存しない読み込み)
      # "zsh/src" ディレクトリ内の .zsh ファイルを全て読み込む
      # (cockpit_logic.zsh という名前に縛られるのをやめる)
      
      # 読み込み対象ディレクトリ
      LOAD_DIR="$HOME/dotfiles/zsh/src"
      
      if [ -d "$LOAD_DIR" ]; then
        # グロブ展開を有効化してループ
        setopt extended_glob
        for f in "$LOAD_DIR"/*.zsh(N); do
          # 読み込み + エラーハンドリング (壊れたファイルがあってもシェルを殺さない)
          if ! source "$f"; then
             echo "⚠️  Failed to load: $(basename "$f")"
          fi
        done
      else
        # ディレクトリ自体がない場合の安全策
        echo "⚠️  Cockpit Logic directory ($LOAD_DIR) not found."
      fi
    '';
  };
}
