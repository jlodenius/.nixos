# Development user configuration
{...}: {
  home-manager.users.jacob = {
    config,
    pkgs,
    ...
  }: {
    home.sessionVariables = {
      GPG_TTY = "$(tty)";
      AWS_PROFILE = "caesari-authentik-saml";
      PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
    };

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "jlodenius";
          email = "jacoblodenius@gmail.com";
        };
        init.defaultBranch = "master";
        pull.rebase = false;
      };
    };

    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = ["--cmd cd"];
    };

    programs.tmux = {
      enable = true;
      extraConfig = builtins.readFile ../../dotfiles/tmux/tmux.conf;
      plugins = with pkgs; [
        tmuxPlugins.vim-tmux-navigator
      ];
    };

    home.packages = with pkgs; [
      gh
      fzf
      ripgrep
      pkg-config
      openssl
      nssTools

      # LSP
      bash-language-server
      tailwindcss-language-server
      emmet-ls
      lua-language-server
      pyright
      nil
      nodePackages.vscode-langservers-extracted # cssls, html
      nodePackages.svelte-language-server
      nodePackages.graphql-language-service-cli
      nodePackages.typescript-language-server
      rust-analyzer

      # Linters & Formatters
      prettierd
      stylua
      alejandra
      ruff
      shellcheck
    ];
  };
}
