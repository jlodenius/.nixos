{...}: {
  flake.nixosModules.xkb = {pkgs, ...}: {
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Gamescope's nested Xwayland ignores Niri's keymap. Set this helper as
    # Lutris → Battle.net → System options → Command prefix.
    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "gamescope-custom-keymap";
        runtimeInputs = [pkgs.libxkbcommon pkgs.xkbcomp];
        text = ''
          : "''${DISPLAY:?gamescope-custom-keymap must run inside Gamescope}"

          keymap="$(mktemp)"
          trap 'rm -f "$keymap"' EXIT

          xkbcli compile-keymap \
            --include "$HOME/.config/xkb" \
            --include-defaults \
            --layout custom \
            --variant basic \
            --options 'lv3:lalt_switch,caps:none,ctrl:nocaps' \
            > "$keymap"

          xkbcomp -w 0 "$keymap" "$DISPLAY"

          rm -f "$keymap"
          trap - EXIT
          exec "$@"
        '';
      })
    ];

    home-manager.users.jacob = {...}: {
      xdg.configFile."xkb/symbols/custom".text =
        builtins.readFile ./custom;
    };
  };
}
