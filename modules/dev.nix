# Development environment — system and user config in one place
{self, ...}: {
  flake.nixosModules.dev = {pkgs, ...}: {
    security.pki.certificateFiles = [
      ../certs/SIS-RootCA.crt
    ];

    networking.hosts = {
      "127.0.0.1" = [
        "mol-dev.sis.se"
        "mol-admin-dev.sis.se"
        "dev-viewer.standard.sis.se"
        "sd-api.dev.sis.se"
      ];
    };

    # Docker
    virtualisation.docker.enable = true;
    users.users.jacob.extraGroups = ["docker"];

    # Required to run unpatched bins (not in nix-store)
    #
    # TODO:
    # Remove if no longer necessary/clean up unused libs, not sure
    # if the ones currently listed are all necessary
    #
    # Used for:
    # 1. AWS auth with playwright
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      xorg.libX11
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrender
      xorg.libXtst
      xorg.libXrandr

      nss
      nspr
      glib
      dbus
      atk
      at-spi2-atk
      libdrm
      expat
      libxcb
      libxkbcommon
      at-spi2-core
      alsa-lib
      cups
      mesa
      libgbm
      pango
      cairo
      stdenv.cc.cc
      openssl
      zlib
    ];

    environment.systemPackages = with pkgs; [
      # Misc
      gcc
      gnumake
      cmake
      cpuset
      gdb
      glib
      lldb
      nodejs
      pnpm

      # Python
      (python3.withPackages (ps:
        with ps; [
          pip
          setuptools

          # Some caesari requirements
          pyzmq
          requests
          protobuf
        ]))
      uv

      # Rust
      rustup
      cargo-expand
      cargo-hack
      cargo-insta
      cargo-machete
      cargo-msrv
      cargo-nextest
      cargo-outdated
    ];

    # ── User-level dev config ──────────────────────────────────────────

    home-manager.users.jacob = {
      config,
      pkgs,
      ...
    }: {
      home.sessionVariables = {
        GPG_TTY = "$(tty)";
        AWS_PROFILE = "caesari-authentik-saml";
        PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
        PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "1";
      };

      services.gpg-agent = {
        enable = true;
        defaultCacheTtl = 1800;
        enableSshSupport = true;
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

      programs.claude-code = {
        enable = true;
        settings = {
          alwaysThinkingEnabled = true;
        };
      };

      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = ["--cmd cd"];
      };

      programs.tmux = {
        enable = true;
        extraConfig = builtins.readFile ../dotfiles/tmux/tmux.conf;
        plugins = with pkgs; [
          tmuxPlugins.vim-tmux-navigator
          (tmuxPlugins.mkTmuxPlugin {
            pluginName = "tmux-scrollback";
            rtpFilePath = "scrollback.tmux";
            version = "unstable";
            src = fetchFromGitHub {
              owner = "jlodenius";
              repo = "tmux-scrollback";
              rev = "master";
              sha256 = "sha256-Z2vD/lEoHRgp7aCMaB44XeicgBb2SZ3b6YkAY/952u4=";
            };
          })
        ];
      };

      home.sessionVariables.EDITOR = "nvim";

      home.packages = with pkgs;
        [
          # Neovim
          self.packages.${pkgs.stdenv.hostPlatform.system}.neovimDynamic

          # Misc
          gh
          fzf
          television
          ripgrep
          pkg-config
          openssl
          protobuf

          # CA
          nssTools
          mkcert

          # AWS
          chamber
          saml2aws
          awscli2
          aws-vault
        ]
        ++ self.lib.lintAndFormat pkgs;
    };
  };
}
