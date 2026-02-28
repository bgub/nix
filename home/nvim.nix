{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Minimal init.lua that bootstraps lazy.nvim and LazyVim on first run
  xdg.configFile."nvim/init.lua" = {
    force = true;
    text = ''
      -- Leader keys
      vim.g.mapleader = " ";
      vim.g.maplocalleader = ","

      -- Bootstrap lazy.nvim
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable",
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)

      -- Setup LazyVim
      require("lazy").setup({
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        -- You can add more specs here or in lua/plugins/*.lua
      }, {
        ui = { border = "rounded" },
        change_detection = { notify = false },
      })
    '';
  };
}
