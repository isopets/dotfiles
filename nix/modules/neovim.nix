{ config, pkgs, ... }:

{
  # Neovim 本体と設定の有効化
  programs.neovim = {
    enable = true;
    defaultEditor = true; # git commit や system のデフォルトエディタとして使う
    viAlias = true;       # vi コマンドも有効化
    vimAlias = true;      # vim コマンドも有効化

    # --- Plugins (LazyVim相当の機能を実現) ---
    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim      # テーマ
      lualine-nvim         # ステータスバー
      telescope-nvim       # FZFライクなファイル探索
      plenary-nvim
      # Nix設定ファイルの色分けに必須
      (nvim-treesitter.withPlugins (p: [
        p.tree-sitter-nix
        p.tree-sitter-lua
      ]))
    ];

    # --- Config (Luaで記述) ---
    extraLuaConfig = ''
      -- テーマ設定
      vim.cmd[[colorscheme tokyonight]]
      
      -- 基本設定
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.clipboard = "unnamedplus" -- システムクリップボード連携
      
      -- 必須機能の有効化
      require('lualine').setup()
      
      -- キーマッピング (Minimalistな機能に限定)
      vim.g.mapleader = " "
      local keymap = vim.keymap.set
      
      keymap("n", "<leader>f", "<cmd>Telescope find_files<cr>")
    '';
  };
}