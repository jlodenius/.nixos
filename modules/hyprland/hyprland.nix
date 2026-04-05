{...}: {
  flake.nixosModules.hyprland = {pkgs, ...}: {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    home-manager.users.jacob = {config, ...}: {
      xdg.configFile."hypr/hyprland.conf".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/modules/hyprland/hyprland.conf";

      xdg.configFile."hypr/dota.conf".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/modules/hyprland/dota.conf";
    };
  };
}
