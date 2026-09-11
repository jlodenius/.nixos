{...}: {
  flake.nixosModules.niri = {pkgs, ...}: {
    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      # 0.8.2 fixes the panic when suspend/hotplug temporarily removes all outputs.
      unstable.xwayland-satellite
    ];

    home-manager.users.jacob = {config, ...}: {
      xdg.configFile."niri/config.kdl".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/modules/niri/config.kdl";

      xdg.configFile."niri/scripts".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/modules/niri/scripts";

      xdg.configFile."autostart/nm-applet.desktop".text = ''
        [Desktop Entry]
        Hidden=true
      '';
    };
  };
}
