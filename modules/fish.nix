{...}: {
  flake.nixosModules.fish = {
    config,
    pkgs,
    ...
  }: let
    c = config.colours;
  in {
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
          format = "$directory$git_branch$git_status$nix_shell$character";

          directory = {
            style = "bold ${c.cyan}";
          };

          git_branch = {
            symbol = " ";
            style = "bold ${c.red}";
          };

          git_status = {
            style = "bold ${c.yellow}";
          };

          character = {
            success_symbol = "[➜](bold ${c.green})";
            error_symbol = "[➜](bold ${c.red})";
          };
        };
      };
    };
  };
}
