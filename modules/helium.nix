{inputs, ...}: {
  flake.nixosModules.helium = {...}: {
    imports = [inputs.helium.nixosModules.default];

    programs.helium = {
      enable = true;

      # Wayland-native rendering (consistent with MOZ_ENABLE_WAYLAND elsewhere).
      flags = [
        "--ozone-platform-hint=auto"
      ];
    };
  };
}
