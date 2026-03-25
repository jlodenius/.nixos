{...}: {
  flake.nixosModules.fish = {pkgs, ...}: {
    home-manager.users.jacob = {pkgs, ...}: {
      home.sessionPath = [
        "$HOME/.local/bin"
      ];

      programs.fish = {
        enable = true;
        shellAliases = {
          kc = "kubectl";
          vim = "nvim";
          bt = "bluetuith";
          lsa = "ls -a";
        };
        functions = {
          nix-shell = ''
            if test (count $argv) -eq 1; and test -f ~/.nixos/shells/$argv[1].nix
              command nix-shell ~/.nixos/shells/$argv[1].nix --command fish
            else
              command nix-shell $argv --command fish
            end
          '';
        };
        interactiveShellInit = ''
          fish_vi_key_bindings
          set -g fish_greeting ""

          complete -c nix-shell -a '(for f in ~/.nixos/shells/*.nix; string replace -r ".*/" "" $f | string replace ".nix" ""; end)'
        '';
        plugins = [
          {
            name = "bass";
            src = pkgs.fishPlugins.bass.src;
          }
          {
            name = "fzf-fish";
            src = pkgs.fishPlugins.fzf-fish.src;
          }
        ];
      };

      programs.starship = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          # Gruvbox Dark Palette colors
          # bg0: #282828, red: #fb4934, green: #b8bb26, yellow: #fabd2f, blue: #83a598

          format = "$directory$git_branch$git_status$nix_shell$character";

          directory = {
            style = "bold #83a598"; # Gruvbox Blue
          };

          git_branch = {
            symbol = " ";
            style = "bold #fb4934"; # Gruvbox Red
          };

          git_status = {
            style = "bold #fabd2f"; # Gruvbox Yellow
          };

          character = {
            success_symbol = "[➜](bold #b8bb26)"; # Gruvbox Green
            error_symbol = "[➜](bold #fb4934)"; # Gruvbox Red
          };
        };
      };
    };
  };
}
