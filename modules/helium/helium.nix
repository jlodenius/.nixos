{inputs, ...}: let
  quickmarks = import ./_quickmarks.nix;
  bookmarks = import ./_bookmarks.nix;
in {
  flake.nixosModules.helium = {lib, ...}: let
    # Render an attrset to "name<TAB>url" lines
    toTsv = set: lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}\t${v}") set) + "\n";
  in {
    imports = [inputs.helium.nixosModules.default];

    home-manager.users.jacob.xdg.configFile = {
      "helium-launcher/quickmarks".text = toTsv quickmarks;
      "helium-launcher/bookmarks".text = toTsv bookmarks;
    };

    programs.helium = {
      enable = true;

      # Wayland-native rendering (consistent with MOZ_ENABLE_WAYLAND elsewhere)
      flags = [
        "--ozone-platform-hint=auto"
      ];

      # Chromium enterprise policies. Reference:
      # https://cloud.google.com/docs/chrome-enterprise/policies/
      policies = {
        BookmarkBarEnabled = false;
        SearchSuggestEnabled = false;
      };
    };
  };
}
