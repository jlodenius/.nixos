{
  inputs,
  self,
  lib,
  ...
}: {
  # Shared formatters & linters — used by both the neovim wrapper and dev.nix
  flake.lib.lintAndFormat = pkgs:
    with pkgs; [
      # Formatters
      rustfmt
      prettierd
      stylua
      alejandra
      ruff

      # Linters
      eslint_d
      shellcheck
      statix
    ];

  flake.nvimWrapper = {
    config,
    wlib,
    lib,
    pkgs,
    ...
  }: {
    imports = [wlib.wrapperModules.neovim];

    options = {
      settings = {
        test_mode = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        wrapped_config = lib.mkOption {
          type = wlib.types.stringable;
          default = ./.;
        };

        unwrapped_config = lib.mkOption {
          type = lib.types.either wlib.types.stringable lib.types.luaInline;
          default = lib.generators.mkLuaInline "vim.uv.os_homedir() .. '/.nixos/packages/neovim'";
        };
      };
    };

    config = {
      settings.config_directory =
        if config.settings.test_mode
        then config.settings.unwrapped_config
        else config.settings.wrapped_config;

      # devMode uses "vim" as binary name so both derivations can coexist
      binName = lib.mkIf config.settings.test_mode (lib.mkDefault "vim");
      settings.dont_link = config.binName != "nvim";

      # ── Extra packages (LSPs, formatters, linters) ─────────────────────
      extraPackages =
        (with pkgs; [
          # LSP
          rust-analyzer
          lua-language-server
          pyright
          nil
          inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.roslyn-ls
          bash-language-server
          tailwindcss-language-server
          emmet-ls
          nodePackages.vscode-langservers-extracted # cssls, html, eslint
          nodePackages.typescript-language-server
          nodePackages.svelte-language-server
          nodePackages.graphql-language-service-cli
        ])
        ++ self.lib.lintAndFormat pkgs;

      specs = {
        initLua = {
          data = null;
          before = ["MAIN_INIT"];
          config = ''
            require('init')
            require('lz.n').load('plugins')
            require('lz.n').load('plugins.lsp')
          '';
        };

        # ── Plugins (always loaded) ────────────────────────────────────────
        start = let
          p = pkgs.vimPlugins;
        in [
          p.lz-n
          p.plenary-nvim
          p.nvim-web-devicons
          p.nvim-treesitter.withAllGrammars
          p.vim-tmux-navigator

          # Colorscheme + transparency
          p.melange-nvim
          p.transparent-nvim

          # Status line
          p.lightline-vim

          # Completion
          p.nvim-cmp
          p.cmp-nvim-lsp
          p.cmp-buffer
          p.cmp-path
          p.cmp_luasnip
          p.luasnip
          p.friendly-snippets

          # LSP
          p.nvim-lspconfig
          p.nvim-lsp-file-operations
          p.roslyn-nvim

          # Needed by comment.nvim at require time
          p.nvim-ts-context-commentstring
        ];

        # ── Plugins (lazy loaded) ──────────────────────────────────────────
        opt = let
          p = pkgs.vimPlugins;
        in {
          lazy = true;
          data = [
            # Navigation
            p.telescope-nvim
            p.telescope-fzf-native-nvim
            p.telescope-undo-nvim
            p.nvim-tree-lua
            p.oil-nvim
            p.harpoon2

            # Git
            p.vim-fugitive
            p.gitsigns-nvim
            (pkgs.vimUtils.buildVimPlugin {
              pname = "vgit-nvim";
              version = "unstable";
              src = pkgs.fetchFromGitHub {
                owner = "tanvirtin";
                repo = "vgit.nvim";
                rev = "7e147e8cb2f160ae3c8d353005666f636d34acb2";
                hash = "sha256-XDLylDFgWnZWt2W3yiH5a5LXxoTm5UanXMVeFqOa3Is=";
              };
              doCheck = false;
            })

            # Editing
            p.comment-nvim
            p.nvim-autopairs
            p.mini-ai
            p.mini-surround
            (pkgs.vimUtils.buildVimPlugin {
              pname = "vim-maximizer";
              version = "unstable";
              src = pkgs.fetchFromGitHub {
                owner = "szw";
                repo = "vim-maximizer";
                rev = "2e54952fe91e140a2e69f35f22131219fcd9c5f1";
                hash = "sha256-+VPcMn4NuxLRpY1nXz7APaXlRQVZD3Y7SprB/hvNKww=";
              };
            })

            # UI
            p.dressing-nvim
            p.trouble-nvim
            p.quicker-nvim

            # Tools
            p.conform-nvim
            p.nvim-lint
            p.crates-nvim
            p.auto-session

            # AI
            (pkgs.vimUtils.buildVimPlugin {
              pname = "99";
              version = "unstable";
              src = pkgs.fetchFromGitHub {
                owner = "ThePrimeagen";
                repo = "99";
                rev = "ec9872f7df7f4eb8b319719c1c253eb3ea8877ed";
                hash = "sha256-z8hafm8EWS7dXoDXnZ/1ddvtpWKVUtJfvQmWT4zXIdg=";
              };
              doCheck = false;
            })
          ];
        };
      };
    };
  };

  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages = {
      # Portable neovim — config baked into nix store
      neovim = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;
        imports = [self.nvimWrapper];
      };

      # Dev mode — reads config from disk for instant edits, binary named "vim"
      devMode = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;
        settings.test_mode = true;
        imports = [self.nvimWrapper];
      };

      # Auto-detects: if the repo is cloned locally, use devMode; otherwise portable
      neovimDynamic = pkgs.writeShellApplication {
        name = "nvim";
        text = ''
          if [ -d ~/.nixos/packages/neovim/lua ]; then
              ${lib.getExe self'.packages.devMode} "$@"
          else
              ${lib.getExe self'.packages.neovim} "$@"
          fi
        '';
      };
    };
  };
}
