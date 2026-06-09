{inputs, ...}: {
  flake.nixosModules.helium = {...}: {
    imports = [inputs.helium.nixosModules.default];

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

        # Force-pin the Bitwarden icon to the toolbar so it's always clickable
        # to unlock (it ships unpinned, hence the "no icon" problem). Unlock and
        # autofill settings are still interactive — this only fixes visibility.
        ExtensionSettings = {
          "nngceckbapebfimnlniiiahkandclblb" = {
            toolbar_pin = "force_pinned";
          };
        };
      };
    };
  };
}
