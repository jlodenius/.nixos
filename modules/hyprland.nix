{...}: {
  flake.nixosModules.hyprland = {pkgs, ...}: {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    xdg.portal = {
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
      ];
      config.common.default = ["hyprland" "gtk"];
    };

    home-manager.users.jacob = {config, ...}: {
      home.sessionVariables = {
        XDG_CURRENT_DESKTOP = "Hyprland";
      };

      xdg.configFile."hypr".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/dotfiles/hypr";
    };
  };
}
