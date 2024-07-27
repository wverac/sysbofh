{
  config,
  pkgs,
  ...
}: let
  symbolsOutlineConfig = ''
     require("symbols-outline").setup {
       highlight_hovered_item = true,
       show_guides = true,
       auto_preview = false,
       position = 'right',
       relative_width = true,
       width = 25,
       auto_close = true,
       show_numbers = false,
       show_relative_numbers = false,
       show_symbol_details = true,
       preview_bg_highlight = 'Pmenu',
       autofold_depth = nil,
       auto_unfold_hover = true,
       fold_markers = { '', '' },
       wrap = false,
       keymaps = {
         close = {"<Esc>", "q"},
         goto_location = "<Cr>",
         focus_location = "o",
         hover_symbol = "<C-space>",
         toggle_preview = "K",
         rename_symbol = "r",
         code_actions = "a",
         fold = "h",
         unfold = "l",
         fold_all = "W",
         unfold_all = "E",
         fold_reset = "R",
       },
       symbols = {
         File = { icon = "", hl = "TSURI" },
         Module = { icon = "", hl = "TSNamespace" },
         Namespace = { icon = "", hl = "TSNamespace" },
         Package = { icon = "", hl = "TSNamespace" },
         Class = { icon = "𝓒", hl = "TSType" },
         Method = { icon = "ƒ", hl = "TSMethod" },
         Property = { icon = "", hl = "TSMethod" },
         Field = { icon = "", hl = "TSField" },
         Constructor = { icon = "", hl = "TSConstructor" },
         Enum = { icon = "ℰ", hl = "TSType" },
         Interface = { icon = "ﰮ", hl = "TSType" },
         Function = { icon = "", hl = "TSFunction" },
         Variable = { icon = "", hl = "TSConstant" },
         Constant = { icon = "", hl = "TSConstant" },
         String = { icon = "𝓐", hl = "TSString" },
         Number = { icon = "#", hl = "TSNumber" },
         Boolean = { icon = "⊨", hl = "TSBoolean" },
         Array = { icon = "", hl = "TSConstant" },
         Object = { icon = "⦿", hl = "TSType" },
         Key = { icon = "🔐", hl = "TSType" },
         Null = { icon = "NULL", hl = "TSType" },
         EnumMember = { icon = "", hl = "TSField" },
         Struct = { icon = "𝓢", hl = "TSType" },
         Event = { icon = "🗲", hl = "TSType" },
         Operator = { icon = "+", hl = "TSOperator" },
         TypeParameter = { icon = "𝙏", hl = "TSParameter" }
       }
     }

     -- vimrc options
     vim.opt.mouse = ""  -- Disabled visual mode on select
     vim.opt.tabstop = 4         -- Number of spaces that a <Tab> in the file counts for
     vim.opt.shiftwidth = 4      -- Number of spaces to use for each step of (auto)indent
     vim.opt.expandtab = true    -- Use spaces instead of tabs
     vim.opt.autoindent = true   -- Copy indent from the current line when starting a new line
     -- Enable line wrapping
     vim.opt.whichwrap:remove({'<', '>', 'b', 's', 'h', 'l', 'H', 'L', ' '})
     vim.opt.whichwrap:append('~')
     vim.opt.whichwrap:remove({'h', 'l'})
     vim.opt.wrap = true
     vim.opt.linebreak = true    -- Break lines at word boundaries
     vim.opt.breakindent = true  -- Maintain indent when wrapping lines
     vim.opt.showbreak = "↪ "    -- Show this character before wrapped lines

    -- Additional LunarVim specific settings (if any)
     lvim.log.level = "warn"
     lvim.format_on_save = true

     -- Setup for built-in plugins
     lvim.builtin.alpha.active = true
     lvim.builtin.alpha.mode = "dashboard"
     lvim.builtin.terminal.active = true
     lvim.builtin.nvimtree.setup.view.side = "left"
     lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

     -- Add key mappings for copy and paste
     vim.api.nvim_set_keymap('n', '<C-c>', '"+y', { noremap = true, silent = true })
     vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { noremap = true, silent = true })
     vim.api.nvim_set_keymap('n', '<C-v>', '"+p', { noremap = true, silent = true })
     vim.api.nvim_set_keymap('v', '<C-v>', '"+p', { noremap = true, silent = true })
     vim.api.nvim_set_keymap('i', '<C-v>', '<C-r>+', { noremap = true, silent = true })

     lvim.keys.normal_mode["<leader>o"] = ":SymbolsOutline<CR>"
     lvim.keys.normal_mode["<leader>a"] = ":%!alejandra -qq<CR>"
  '';

  nilLsConfig = ''
    local lspconfig = require('lspconfig')

    lspconfig.nil_ls.setup {
      on_attach = function(client, bufnr)
        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings
        local opts = { noremap=true, silent=true }

        -- Key mappings
        buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
        buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
        buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
        buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
        buf_set_keymap('n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
        buf_set_keymap('n', '<space>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
        buf_set_keymap('n', '<space>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
        buf_set_keymap('n', '<space>D', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
        buf_set_keymap('n', '<space>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
        buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
        buf_set_keymap('n', '<space>e', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
        buf_set_keymap('n', '[d', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
        buf_set_keymap('n', ']d', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
        buf_set_keymap('n', '<space>q', '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
        buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
      end,

      flags = {
        debounce_text_changes = 150,
      },

      settings = {
        ['nil'] = {
                nix = {
        autoArchive = true,
      },
          formatting = {
            command = { "nixpkgs-fmt" }
          },
        },
      },
    }
  '';
in {
  config = {
    home.packages = with pkgs; [
      lunarvim
      pkgs.nil
    ];

    home.file."${config.xdg.configHome}/lvim/config.lua".text = ''

                  -- Function to insert the shebang line
                  function AddShebang()
                    if vim.bo.filetype == 'python' then
                      vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env python3' })
                    end
                  end

                  -- Keybind to call the function
                  vim.api.nvim_set_keymap('n', '<leader>np', ':lua AddShebang()<CR>', { noremap = true, silent = true })

                  -- lvim.colorscheme = "gruvbox"
                  lvim.transparent_window = true

                  lvim.plugins = {
                    { "simrat39/symbols-outline.nvim" },
                    { "mfussenegger/nvim-lint" },
                  }
                  -- Configure nvim-lint
                    require('lint').linters_by_ft = {
                    sh = { 'shellcheck' },
                   }
                   vim.cmd [[
              autocmd BufWritePost <buffer> lua require('lint').try_lint()
            ]]
                  ${symbolsOutlineConfig}
                  ${nilLsConfig}
    '';
  };
}
