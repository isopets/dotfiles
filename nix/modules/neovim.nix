{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim lualine-nvim telescope-nvim plenary-nvim
      (nvim-treesitter.withPlugins (p: [ p.tree-sitter-nix p.tree-sitter-lua ]))
    ];
    extraLuaConfig = ''
      vim.cmd[[colorscheme tokyonight]]
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.clipboard = "unnamedplus"
      require('lualine').setup()
      vim.g.mapleader = " "
      local keymap = vim.keymap.set
      keymap("n", "<leader>f", "<cmd>Telescope find_files<cr>")
    '';
  };
}
