{...}: {
  flake.nixosModules.claude = {...}: {
    home-manager.users.jacob = {pkgs, ...}: {
      programs.claude-code = {
        enable = true;
        settings = {
          alwaysThinkingEnabled = true;
          hooks = {
            Notification = [
              {
                hooks = [
                  {
                    type = "command";
                    command = ''
                      msg=$(${pkgs.jq}/bin/jq -r '.message')
                      ${pkgs.libnotify}/bin/notify-send -a "Claude Code" -i terminal "Claude Code" "$msg"
                    '';
                  }
                ];
              }
            ];
          };
        };
        memory.text = ''
          # Environment
          This is a NixOS system. LSPs are managed declaratively through Nix and
          bundled into the neovim wrapper. Do NOT suggest installing language servers
          — they are already available in the editor.
        '';
      };
    };
  };
}
