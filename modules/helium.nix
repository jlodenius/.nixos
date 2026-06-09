{inputs, ...}: let
  quickmarks = {
    ai = "https://claude.ai/new";
    cal = "https://calendar.google.com";
    ch = "https://www.chess.com";
    gh = "https://github.com/jlodenius";
    gm = "https://mail.google.com/mail/u/0/#inbox";
    maps = "https://www.google.com/maps";
    rd = "https://www.reddit.com";
    yt = "https://www.youtube.com";
    z = "https://mail.zoho.eu/zm/#mail/folder/inbox";
  };
in {
  flake.nixosModules.helium = {lib, ...}: {
    imports = [inputs.helium.nixosModules.default];

    # Render quickmarks to ~/.config/helium-palette/quickmarks as "name<TAB>url"
    # lines; the helium-palette.sh script prepends these above bookmarks.
    home-manager.users.jacob.xdg.configFile."helium-palette/quickmarks".text =
      lib.concatStringsSep "\n"
      (lib.mapAttrsToList (name: url: "${name}\t${url}") quickmarks)
      + "\n";

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
