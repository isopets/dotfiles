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
      # [NEW] エディタ選択を edit に統合
      e = "edit"; # 'e' で edit を起動
      
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

      # 2. Unified Interface: edit コマンド (実装より意図)
      function edit() {
          local file="${1:-.}"
          # フォルダ、または100KBより大きいファイルは VS Code で開く
          if [ ! -f "$file" ] || [ $(stat -f %z "$file" 2>/dev/null || echo 0) -gt 100000 ]; then
              gum style --foreground 33 "🚀 Launching VS Code for $file..."
              code "$file"
          else
              # 小さな設定ファイルなどは Neovim で爆速起動
              gum style --foreground 150 "⚡ Launching Neovim for $file..."
              nvim "$file"
          fi
      }

      # 3. Load Components
      # ... (既存のコードはそのまま維持)
    '';
  };
}