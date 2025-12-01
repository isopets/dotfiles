{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # --- ⚡️ Hyper Aliases ---
    shellAliases = {
      # Cockpit Core
      d = "dev";
      w = "work";
      m = "mkproj";
      f = "finish-work";
      
      # AI & Edit
      a = "ask";
      c = "gcm";
      e = "edit";
      
      # Tools
      g = "lazygit";
      l = "eza -la --icons --git";
      cat = "bat";
      z = "zoxide";
      zj = "zellij"; # Workspace
      
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    # --- 🧠 Zsh Logic (Immutable Setup) ---
    initExtra = ''
      # 1. System Context
      export DOTFILES="$HOME/dotfiles"
      export PATH="$HOME/.nix-profile/bin:$PATH"
      setopt +o nomatch
      setopt interactivecomments

      # 2. FZF-Tab Config (Visual Completion)
      # Nixストアからプラグインを直接ロード
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      
      # FZF-Tab Styling
      zstyle ':completion:*:git-checkout:*' sort false
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 {}'

      # 3. Load Live-Logic (Cockpit Core)
      # ここで外部ファイルを読み込むことで、nix-upなしでの即時編集を可能にする
      if [ -f "$HOME/dotfiles/zsh/cockpit_logic.zsh" ]; then
        source "$HOME/dotfiles/zsh/cockpit_logic.zsh"
      fi
    '';
  };
}
