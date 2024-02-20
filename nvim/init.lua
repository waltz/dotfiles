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

require("lazy").setup({
  { "neanias/everforest-nvim", version = false, lazy = false, priority = 1000, },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },
  { "airblade/vim-gitgutter" },
  { "nvim-telescope/telescope.nvim", tag = "0.1.5", dependencies = { 'nvim-lua/plenary.nvim' } },
  { "nvim-treesitter/nvim-treesitter" },
})

vim.cmd([[colorscheme everforest]])

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    'tsserver',
    'rust_analyzer',
    'ruby_ls',
    'rubocop',
  }
})
require('mason-lspconfig').setup_handlers {
  function (server_name) 
    require('lspconfig')[server_name].setup {}
  end,
}

vim.opt.number = true

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
