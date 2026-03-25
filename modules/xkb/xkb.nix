# Custom XKB layout — US with åöä remap
{...}: {
  flake.nixosModules.xkb = {...}: {
    services.xserver.xkb = {
      layout = "custom,se";
      variant = "";
    };

    home-manager.users.jacob = {...}: {
      xdg.configFile."xkb/symbols/custom".text =
        builtins.readFile ./custom;

      # Sets XKB env for Wayland compositors
      home.sessionVariables = {
        XKB_DEFAULT_LAYOUT = "custom,se";
        XKB_DEFAULT_VARIANT = "basic";
        XKB_DEFAULT_OPTIONS = "lv3:lalt_switch,caps:none,ctrl:nocaps";
      };
    };
  };
}
