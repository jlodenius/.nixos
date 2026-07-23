{...}: {
  flake.nixosModules.claude = {config, ...}: let
    y = config.colours.yellow;
    hexBytes = "0x${builtins.substring 1 2 y} 0x${builtins.substring 3 2 y} 0x${builtins.substring 5 2 y}";
  in {
    home-manager.users.jacob = {pkgs, ...}: {
      programs.claude-code = {
        enable = true;
        package = pkgs.unstable.claude-code;
        settings = {
          alwaysThinkingEnabled = true;
          statusLine = {
            type = "command";
            command = ''
              rgb=$(printf '%d;%d;%d' ${hexBytes})
              ${pkgs.jq}/bin/jq -r --arg rgb "$rgb" '"\u001b[38;2;\($rgb)m\(.model.display_name)  \(.workspace.current_dir | sub("^"+env.HOME;"~"))  ctx: \((.context_window.total_input_tokens // 0) / 1000 | floor)k\u001b[0m"'
            '';
          };
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
                          # and auto-clear this prompt per session. Inside tmux
                          # the ancestry dead-ends at the server, so start from
                          # the attached client instead — it lives in the terminal.
                          win=""
                          pid=$$
                          if [ -n "$TMUX" ]; then
                            pid=$(${pkgs.tmux}/bin/tmux display-message -p '#{client_pid}' 2>/dev/null || echo $$)
                          fi
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

          # Comments
          Default to writing NO comments. Never comment self-explanatory code —
          if the line already says what it does, the comment is bloat. Only
          write one when it genuinely adds value: non-obvious rationale, a
          workaround, a subtle constraint that isn't visible in the code. When
          in doubt, leave it out.
        '';
      };
    };
  };
}
