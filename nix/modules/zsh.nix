{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

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

    # 🚨 修正: src フォルダ内の全ファイルを読み込む
    initContent = ''
      # 1. FZF-Tab
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      
      # 2. Load Modular Source Files
      LOAD_DIR="$HOME/dotfiles/zsh/src"
      if [ -d "$LOAD_DIR" ]; then
        for f in "$LOAD_DIR/"*.zsh; do
          if [ -r "$f" ]; then
             source "$f"
          fi
        done
      fi

      # 3. Init Hooks
      command -v starship >/dev/null && eval "$(starship init zsh)"
      command -v direnv >/dev/null && eval "$(direnv hook zsh)"
      [ -f "$(which navi)" ] && eval "$(navi widget zsh)"
    '';
  };
}
