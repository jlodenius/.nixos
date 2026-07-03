{inputs, ...}: {
  flake.nixosModules.helium = {...}: {
    imports = [inputs.helium.nixosModules.default];

    # Point the launcher's quickmarks/bookmarks at mutable files in this repo
    # via out-of-store symlinks, so edits take effect immediately — no rebuild.
    # Format is "<label> <url>" per line; blank lines and '#' comments are
    # allowed. Consumed by quickshell's HeliumPicker (Mod+O).
    home-manager.users.jacob = {
      config,
      pkgs,
      ...
    }: {
      xdg.configFile = {
        "helium-launcher/quickmarks".source =
          config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/.nixos/modules/helium/_quickmarks";
        "helium-launcher/bookmarks".source =
          config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/.nixos/modules/helium/_bookmarks";

        # Widevine DRM (Netflix, Spotify, etc.). Helium is ungoogled-Chromium
        # based, so no CDM ships and auto-download is disabled — provide it in
        # the component layout Helium reads from its user-data dir.
        "net.imput.helium/WidevineCdm/${pkgs.widevine-cdm.version}".source = "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm";
        "net.imput.helium/WidevineCdm/latest-component-updated-widevine-cdm".text = builtins.toJSON {
          Path = "${config.xdg.configHome}/net.imput.helium/WidevineCdm/${pkgs.widevine-cdm.version}";
        };
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
