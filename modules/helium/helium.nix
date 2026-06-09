{inputs, ...}: let
  # Nix-managed launcher entries (single source of truth), each in its own file.
  quickmarks = import ./_quickmarks.nix;
  bookmarks = import ./_bookmarks.nix;
in {
  flake.nixosModules.helium = {lib, ...}: let
    # Render an attrset to "name<TAB>url" lines — the format the launcher reads.
    toTsv = set: lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}\t${v}") set) + "\n";
  in {
    imports = [inputs.helium.nixosModules.default];

    # Quickmarks + bookmarks for the Helium launcher (helium-launcher.sh),
    # rendered to ~/.config/helium-palette/{quickmarks,bookmarks}.
    home-manager.users.jacob.xdg.configFile = {
      "helium-palette/quickmarks".text = toTsv quickmarks;
      "helium-palette/bookmarks".text = toTsv bookmarks;
    };

    programs.helium = {
      enable = true;

      # Wayland-native rendering (consistent with MOZ_ENABLE_WAYLAND elsewhere).
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
