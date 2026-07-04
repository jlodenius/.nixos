{...}: {
  flake.nixosModules.claude = {...}: {
    home-manager.users.jacob = {pkgs, ...}: {
      programs.claude-code = {
        enable = true;
        package = pkgs.unstable.claude-code;
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
                      case "$msg" in
                        *permission*)
                          # Walk up the process tree to the ancestor that owns a
                          # niri window (the terminal), so quickshell can jump to
                          # and auto-clear this prompt per session.
                          win=""
                          pid=$$
                          while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
                            win=$(${pkgs.niri}/bin/niri msg -j windows 2>/dev/null \
                              | ${pkgs.jq}/bin/jq -r --argjson p "$pid" '[.[] | select(.pid == $p)][0].id // empty')
                            [ -n "$win" ] && break
                            pid=$(${pkgs.gawk}/bin/awk '/^PPid:/ {print $2}' /proc/$pid/status 2>/dev/null)
                          done
                          ${pkgs.libnotify}/bin/notify-send -a "Claude Code" -i terminal \
                            ''${win:+--hint=int:niri-window:$win} "Claude Code" "$msg"
                          ;;
                      esac
                    '';
                  }
                ];
              }
            ];
          };
        };
        context = ''
          # Environment
          This is a NixOS system. LSPs are managed declaratively through Nix and
          bundled into the neovim wrapper. Do NOT suggest installing language servers
          — they are already available in the editor.
        '';
      };
    };
  };
}
