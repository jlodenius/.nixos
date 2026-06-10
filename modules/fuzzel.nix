{...}: {
  flake.nixosModules.fuzzel = {
    config,
    lib,
    ...
  }: let
    c = config.colours;
    # Fuzzel wants RRGGBBAA hex with no leading '#'.
    hex = col: lib.removePrefix "#" col;

    # Shared palette block, sourced from the global colours module so fuzzel
    # matches mako/waybar/yazi/etc.
    colours = ''
      [colors]
      background=${hex c.background}ff
      text=${hex c.foreground}ff
      prompt=${hex c.subtle}ff
      input=${hex c.foreground}ff
      placeholder=${hex c.comment}ff
      match=${hex c.yellow}ff
      selection=${hex c.selection}ff
      selection-text=${hex c.foreground}ff
      selection-match=${hex c.yellow}ff
      counter=${hex c.comment}ff
      border=${hex c.surface}ff

      [border]
      width=2
      radius=12
    '';
  in {
    home-manager.users.jacob = {
      # Global config: any plain `fuzzel` invocation picks up the palette.
      xdg.configFile."fuzzel/fuzzel.ini".text = ''
        [main]
        font=Geist Mono:size=11

        ${colours}
      '';

      # Dedicated config for the helium-launcher (passed via --config). Keeps the
      # launcher-specific layout/keybindings and adds the shared palette.
      xdg.configFile."fuzzel/helium-launcher.ini".text = ''
        [main]
        prompt=
        font=Geist Mono:size=11
        lines=12
        width=70
        tabs=4

        [key-bindings]
        # Free Ctrl+K from its default (delete-line-forward) so it can move selection up.
        delete-line-forward=none
        prev=Up Control+k
        next=Down Control+j

        ${colours}
      '';
    };
  };
}
