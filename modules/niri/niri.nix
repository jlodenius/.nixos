{...}: let
  # Single source of truth: reuse the qutebrowser quickmarks for the Helium
  # bookmark palette (helium-palette script) too.
  quickmarks = (import ../qutebrowser/_bookmarks.nix).quickmarks;
in {
  flake.nixosModules.niri = {
    pkgs,
    lib,
    ...
  }: {
    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];

    home-manager.users.jacob = {config, ...}: {
      xdg.configFile."niri/config.kdl".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/modules/niri/config.kdl";

      xdg.configFile."niri/scripts".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/modules/niri/scripts";

      # Quickmarks for the Helium bookmark palette, written as "name<TAB>url"
      # lines. The palette prepends these above bookmarks so they rank first.
      xdg.configFile."helium-palette/quickmarks".text =
        lib.concatStringsSep "\n"
        (lib.mapAttrsToList (name: url: "${name}\t${url}") quickmarks)
        + "\n";

      xdg.configFile."autostart/nm-applet.desktop".text = ''
        [Desktop Entry]
        Hidden=true
      '';
    };
  };
}
