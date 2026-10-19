-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Options
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.scrolloff = 10
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.listchars = { space = "·", tab = ">–" }
vim.opt.list = true

-- 2-space indent for languages that conventionally use it
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "ruby", "javascript", "typescript", "javascriptreact", "typescriptreact",
    "lua", "yaml", "json", "html", "css" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Clear search highlight on Esc
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic quickfix
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Split navigation with Ctrl+hjkl
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus left" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus right" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus up" })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank() end,
})

-- LSP keymaps (applied when any LSP attaches)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or "n", keys, func, { buffer = ev.buf, desc = desc })
    end
    map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
    map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "v" })
    map("K", vim.lsp.buf.hover, "Hover")
  end,
})

-- Native LSP server configs (nvim 0.11+ API)
vim.lsp.config.pyright = {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
}

vim.lsp.config.jdtls = {
  cmd = { vim.fn.stdpath("data") .. "/mason/bin/jdtls" },
  filetypes = { "java" },
  root_markers = { "pom.xml", "build.gradle", "build.gradle.kts", ".git" },
}

vim.lsp.enable({ "pyright", "jdtls" })

-- Servers configured by nvim-lspconfig and installed by mason-lspconfig
local lspconfig_servers = { "ts_ls", "eslint", "rust_analyzer", "ruby_lsp", "rubocop" }
vim.lsp.enable(lspconfig_servers)

require("lazy").setup({
  -- Dracula theme
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
    init = function() vim.cmd.colorscheme("dracula") end,
  },

  -- Mason (manages LSP server installs)
  { "williamboman/mason.nvim", opts = {} },
  { "neovim/nvim-lspconfig" },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = { ensure_installed = lspconfig_servers, automatic_enable = false },
  },

  -- Git change signs in the sign column
  { "airblade/vim-gitgutter" },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path" },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args) vim.snippet.expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

  -- Telescope (fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({})
      pcall(telescope.load_extension, "fzf")

      -- Work around treesitter API mismatch in Telescope's preview highlighter
      -- on newer Neovim (ts_highlighter still assumes the old start() signature)
      local preview_utils = require("telescope.previewers.utils")
      preview_utils.ts_highlighter = function(bufnr, ft)
        local lang = vim.treesitter.language.get_lang(ft) or ft
        if not lang or lang == "" then
          return false
        end
        return pcall(vim.treesitter.start, bufnr, lang)
      end

      local builtin = require("telescope.builtin")

      -- crisp top-level bindings, matching old plain-vim muscle memory
      vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })

      -- [F]ind prefix
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })

      -- [S]earch prefix
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = "[S]earch Recent Files" })
      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
      vim.keymap.set("n", "<leader>s/", builtin.current_buffer_fuzzy_find, { desc = "[S]earch [/] in Current Buffer" })
      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[S]earch [N]eovim files" })

      -- Standalone
      vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Find existing buffers" })
      vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "[/] Grep in current buffer" })

      -- LSP pickers (buffer-local on attach)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
        callback = function(event)
          local buf = event.buf
          vim.keymap.set("n", "grr", builtin.lsp_references, { buffer = buf, desc = "[G]oto [R]eferences" })
          vim.keymap.set("n", "gri", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementation" })
          vim.keymap.set("n", "grd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
          vim.keymap.set("n", "grt", builtin.lsp_type_definitions, { buffer = buf, desc = "[G]oto [T]ype Definition" })
          vim.keymap.set("n", "gO", builtin.lsp_document_symbols, { buffer = buf, desc = "Document Symbols" })
          vim.keymap.set("n", "gW", builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = "Workspace Symbols" })
        end,
      })
    end,
  },

  -- nvim-tree (file explorer sidebar)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      vim.keymap.set("n", "<C-\\>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    end,
  },

  -- Treesitter (syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "python", "java", "lua", "json", "yaml", "markdown", "vim",
          "javascript", "typescript", "html", "css", "dockerfile", "ruby", "go", "rust" },
      })
    end,
  },
})

-- Machine-specific overrides
local local_config = vim.fn.stdpath("config") .. "/local.lua"
if vim.uv.fs_stat(local_config) then
  dofile(local_config)
end
