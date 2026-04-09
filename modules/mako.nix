{...}: {
  flake.nixosModules.mako = {
    config,
    pkgs,
    ...
  }: let
    c = config.colours;
  in {
    home-manager.users.jacob = {
      services.mako = {
        enable = true;
        settings = {
          background-color = "${c.background}FF";
          text-color = "${c.foreground}FF";
          border-color = "${c.surface}FF";
          border-radius = 12;
          border-size = 1;
          padding = "14";
          margin = "18";
          font = "Geist Mono 11";
          icon-location = "left";
          icon-path = "${pkgs.adwaita-icon-theme}/share/icons";
          max-icon-size = 48;
          icons = true;
          default-timeout = 5000;

          "urgency=critical" = {
            border-color = "${c.red}FF";
          };
        };
      };
    };
  };
}
