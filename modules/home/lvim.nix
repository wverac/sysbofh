{
  config,
  pkgs,
  ...
}: {
  config = {
    home.packages = with pkgs; [
      lunarvim
      pkgs.nil
      yaml-language-server
      nodePackages.bash-language-server
      terraform-ls
      vscode-langservers-extracted
      ansible-language-server
      bash-language-server
      dockerfile-language-server-nodejs
      terraform-ls
      yaml-language-server
    ];

    home.file."${config.xdg.configHome}/lvim/config.lua".text = ''
       -- sysBOFH

       -- lvim.colorscheme = "gruvbox"
       lvim.transparent_window = true

       lvim.plugins = {
          { "simrat39/symbols-outline.nvim" },
       }

       -- Custom keybindings
       lvim.keys.normal_mode["<leader>o"] = ":SymbolsOutline<CR>"
       lvim.keys.normal_mode["<leader>ale"] = ":%!alejandra -qq<CR>"
       lvim.keys.normal_mode["<leader>np"] = ":lua AddShebang()<CR>", { noremap = true, silent = true }
       lvim.keys.normal_mode["<leader>ss"] = ":lua AddBashShebang()<CR>", { noremap = true, silent = true }
       -- Tab Navigation Keybindings
       lvim.keys.normal_mode["gt"] = ":BufferLineCycleNext<CR>"
       lvim.keys.normal_mode["gT"] = ":BufferLineCyclePrev<CR>"
       -- LSP Keybindings
       lvim.lsp.default_keybindings = true

       -- Function to insert the shebang line
       function AddShebang()
         if vim.bo.filetype == 'python' then
             vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env python3' })
           end
       end

       function AddBashShebang()
         if vim.bo.filetype == 'sh' or vim.bo.filetype == 'bash' then
           vim.api.nvim_buf_set_lines(0, 0, 0, false, { '#!/usr/bin/env bash' })
          end
       end

       -- vimrc options
       vim.opt.mouse = ""
       vim.opt.tabstop = 4
       vim.opt.shiftwidth = 4
       vim.opt.expandtab = true
       vim.opt.autoindent = true
       -- Enable line wrapping
       vim.opt.whichwrap:remove({'<', '>', 'b', 's', 'h', 'l', 'H', 'L', ' '})
       vim.opt.whichwrap:append('~')
       vim.opt.whichwrap:remove({'h', 'l'})
       vim.opt.wrap = true
       vim.opt.linebreak = true
       vim.opt.breakindent = true
       vim.opt.showbreak = "↪ "
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

       -- Enable indent lines
       lvim.builtin.indentlines.active = true

       -- Configuration for indent-blankline.nvim
       lvim.builtin.indentlines.options = {
           char = "│", -- Choose the character for vertical lines
           show_current_context = true, -- Highlight the current context
           show_trailing_blankline_indent = false, -- Disable trailing lines
           use_treesitter = true, -- Use Treesitter for better indentation
           use_treesitter_scope = true, -- Highlight scope boundaries
       }

       --Set colors for the indent lines
       vim.cmd([[
       highlight IndentBlanklineChar guifg=#2a2e36 gui=nocombine
       highlight IndentBlanklineContextChar guifg=#a3be8c gui=nocombine
       ]])

       -- LSP
       local lspconfig = require('lspconfig')
       lspconfig.nil_ls.setup {
         flags = {
           debounce_text_changes = 150,
         },
         settings = {
           ['nil'] = {
             nix = {
               autoArchive = true,
             },
             formatting = {
               command = { "alejandra" }
             },
           },
         },
       }
       lspconfig.pyright.setup{}
       lspconfig.lua_ls.setup {}
       lspconfig.yamlls.setup {
         settings = {
           yaml = {
             schemas = {
               ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
               ["https://json.schemastore.org/github-action.json"] = "/.github/actions/*",
               ["https://json.schemastore.org/kubernetes.json"] = "/*.k8s.yaml",
               ["https://json.schemastore.org/ansible-playbook.json"] = "/*ansible*.yml",

             },
            validate = true,
            hover = true,
            completion = true,
           },
         },
       }

       lspconfig.bashls.setup {
         filetypes = { "sh", "bash" },
         cmd = { "bash-language-server", "start" },
         on_attach = function(client, bufnr)
         end,
       }

       lspconfig.terraformls.setup {
         cmd = { "terraform-ls", "serve" },
         filetypes = { "terraform", "tf" },
         root_dir = lspconfig.util.root_pattern(".terraform", ".git"),
         on_attach = function(client, bufnr)
         end,
       }

       lspconfig.jsonls.setup {
         cmd = { "vscode-json-language-server", "--stdio" },
         filetypes = { "json", "jsonc" },
         settings = {
             json = {
                 schemas = {
                     {
                     description = "Schema for GitHub Workflows",
                     fileMatch = { ".github/workflows/*.json" },
                     url = "https://json.schemastore.org/github-workflow.json",
                     },
                     {
                     description = "Schema for Ansible Playbooks",
                     fileMatch = { "ansible*.json" },
                     url = "https://json.schemastore.org/ansible-playbook.json",
                     },
                 },
             },
         },
       on_attach = function(client, bufnr)
       end,
       }

       -- Outline symbols
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

    '';
  };
}
