{inputs, ...}: {
  flake.nixosModules.helium = {...}: {
    imports = [inputs.helium.nixosModules.default];

    # Point the launcher's quickmarks/bookmarks at mutable files in this repo
    # via out-of-store symlinks, so edits take effect immediately — no rebuild.
    # Format is "<label> <url>" per line; blank lines and '#' comments are
    # allowed (the launcher script strips them). See helium-launcher.sh.
    home-manager.users.jacob = {config, ...}: {
      xdg.configFile = {
        "helium-launcher/quickmarks".source =
          config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/.nixos/modules/helium/quickmarks";
        "helium-launcher/bookmarks".source =
          config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/.nixos/modules/helium/bookmarks";
      };
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
