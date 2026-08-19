{...}: {
  flake.nixosModules.xkb = {...}: {
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    home-manager.users.jacob = {...}: {
      xdg.configFile."xkb/symbols/custom".text =
        builtins.readFile ./custom;
    };
  };
}
