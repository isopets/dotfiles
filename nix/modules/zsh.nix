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

      # Paste Safety
      autoload -Uz bracketed-paste-magic
      zle -N bracketed-paste bracketed-paste-magic
      # URLなどを貼り付けた時の勝手なエスケープを防止
      autoload -Uz url-quote-magic
      zle -N self-insert url-quote-magic

        # --- 🛡️ Clipboard Safety Mechanism ---
      # pbpaste (macOS) を使って、クリップボードの中身を直接ファイルに吐き出す
      # Usage: コピーした後、'pf filename' と打つだけ
      function pf() {
          local file="$1"
          if [ -z "$file" ]; then
              echo "❌ Usage: Copy text, then run 'pf <filename>'"
              return 1
          fi
          
          # Macのクリップボード(pbpaste)から直接書き込む
          if command -v pbpaste >/dev/null; then
              pbpaste > "$file"
              echo "✅ Pasted clipboard content to '$file' (Securely)"
              # 中身をチラ見せ確認
              head -n 3 "$file"
              echo "..."
          else
              echo "❌ 'pbpaste' not found. Are you on macOS?"
          fi
      }

      # 2. FZF-Tab Config
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      zstyle ':completion:*:git-checkout:*' sort false
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
      zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:500 {}'

      # 3. Unified Interface: edit
      function edit() {
          local file="''${1:-.}"
          if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
              gum style --foreground 33 "🚀 Launching VS Code for $file..."
              code "$file"
          else
              gum style --foreground 150 "⚡ Launching Neovim for $file..."
              nvim "$file"
          fi
      }

      # 4. Load Secrets
      [ -f "$DOTFILES/.env" ] && source "$DOTFILES/.env"

      # 5. Load Functions (ここが最重要！確実に読み込みます)
      if [ -d "$DOTFILES/zsh/functions" ]; then
        for f in "$DOTFILES/zsh/functions/"*.zsh; do
          [ -r "$f" ] && source "$f"
        done
      else
        echo "⚠️ Warning: Functions directory not found!"
      fi

      # 6. Init Tools & Aliases
      alias ai="ask"
      command -v starship >/dev/null && eval "$(starship init zsh)"
      command -v direnv >/dev/null && eval "$(direnv hook zsh)"
    '';
  };
}
