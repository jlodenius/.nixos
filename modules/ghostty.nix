{...}: {
  flake.nixosModules.ghostty = {...}: {
    home-manager.users.jacob = {
      programs.ghostty = {
        enable = true;
        settings = {
          font-family = "Geist Mono";
          font-size = 16;
          font-feature = ["-calt" "-liga" "-dlig"];

          background = "#000";
          background-opacity = 0.8;

          window-padding-x = 5;
          window-padding-y = 5;
        };
      };
    };
  };
}
