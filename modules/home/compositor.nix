# Personal user configuration (GUI + personal services)
{stockfin, ...}: {
  home-manager.users.jacob = {
    config,
    pkgs,
    zen-browser,
    ...
  }: {
    # Note:
    # Important that these imports are inside the home-manager and not at top-level, because then it would
    # be considered system packages
    imports = [
      ./fish.nix
      ./dark-theme.nix
      ./symlinks.nix
    ];

    home.stateVersion = "25.11";

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      GTK_THEME = "Adwaita:dark";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_CURRENT_DESKTOP = "Hyprland";
    };

    # Set up directories
    xdg.userDirs = {
      enable = true;
      createDirectories = true;

      # Create these
      download = "${config.home.homeDirectory}/Downloads";
      documents = "${config.home.homeDirectory}/Documents";
      pictures = "${config.home.homeDirectory}/Pictures";

      # And ignore these
      desktop = "${config.home.homeDirectory}";
      music = "${config.home.homeDirectory}";
      videos = "${config.home.homeDirectory}";
      templates = "${config.home.homeDirectory}";
      publicShare = "${config.home.homeDirectory}";
    };
    home.file."Pictures/screenshots/.keep".text = "";

    # User packages
    home.packages = with pkgs; [
      # System & UI
      ghostty
      waybar
      vicinae
      bluetuith
      grim
      slurp
      hyprpolkitagent
      hyprpaper
      swaynotificationcenter
      swaylock

      # CLI utils
      fd
      wl-clipboard
      rofi
      keyutils
      unzip

      # Applications
      stockfin.packages.${pkgs.stdenv.hostPlatform.system}.default
      zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      qutebrowser
      google-chrome
      discord
      slack
      nordpass
      bitwarden-desktop
      bitwarden-cli
      spotify
      pavucontrol
      yazi
      mpv
      networkmanagerapplet
      postman
    ];

    # rbw - fast Bitwarden CLI (uses background daemon for instant lookups)
    programs.rbw = {
      enable = true;
      settings = {
        base_url = "https://vault.bitwarden.eu";
        email = "jacob@lodenius.com";
        pinentry = pkgs.pinentry-rofi;
      };
    };
  };
}
