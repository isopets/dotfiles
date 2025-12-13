{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # --- 1. Aliases (Nix Managed) ---
    shellAliases = {
      # Visuals
      ls = "eza --icons --git --group-directories-first";
      ll = "eza --icons --git -l --group-directories-first";
      cat = "bat";
      grep = "rg";
      
      # Operations
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";
      
      # Cockpit Shortcuts
      sz = "reload";
      mk = "mkproj";
      w  = "work";       # ← 追加: 仕事モード用
      dev = "dashboard";
      home = "dashboard"; # ← 維持: ダッシュボード用
      help = "tldr";      # ← 維持: ヘルプ用
    };

    # --- 2. Init Script (Safe Mode) ---
    initExtra = ''
      # 1. FZF-Tab
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # 2. Cockpit Loader (外部モジュール読み込み)
      if [ -f "$HOME/dotfiles/zsh/src/loader.zsh" ]; then
        source "$HOME/dotfiles/zsh/src/loader.zsh"
      fi
      
      # 3. Reload Function (Safe Alias)
      # function {...} を使うとエラーになるので、aliasで安全に定義
      alias reload="source ~/.zshrc && echo '✅ Config Reloaded.'"
    '';
  };
}
