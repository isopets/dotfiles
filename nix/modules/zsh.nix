{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # --- ⚡️ Hyper Aliases ---
    shellAliases = {
      d = "dev";
      w = "work";
      m = "mkproj";
      f = "finish-work";
      a = "ask";
      c = "gcm";
      e = "edit";
      
      g = "lazygit";
      l = "eza -la --icons --git";
      cat = "bat";
      z = "zoxide";
      ".." = "cd ..";
      "..." = "cd ../..";
    };

    # --- 🧠 Zsh Logic (Immutable) ---
    initExtra = ''
      # 1. System Context
      export DOTFILES="$HOME/dotfiles"
      export PATH="$HOME/.nix-profile/bin:$PATH"
      setopt +o nomatch
      setopt interactivecomments

      # 2. FZF-Tab Config (Visual Completion)
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      zstyle ':completion:*:git-checkout:*' sort false
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 {}'

      # 3. Unified Interface: edit コマンド
      function edit() {
          # 🚨 修正箇所: Nixのエスケープ ''${...} を使用
          local file="''${1:-.}"
          
          if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
              gum style --foreground 33 "🚀 Launching VS Code for $file..."
              code "$file"
          else
              gum style --foreground 150 "⚡ Launching Neovim for $file..."
              nvim "$file"
          fi
      }

      # 4. Load Components
      [ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"
      
      if [ -d "$DOTFILES/zsh/functions" ]; then
        for f in "$DOTFILES/zsh/functions/"*.zsh; do
          [ -r "$f" ] && source "$f"
        done
      fi

      # 5. Init Tools
      command -v starship >/dev/null && eval "$(starship init zsh)"
      command -v direnv >/dev/null && eval "$(direnv hook zsh)"
    '';
  };
}
