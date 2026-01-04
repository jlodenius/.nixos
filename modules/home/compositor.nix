# Personal user configuration (GUI + personal services)
{...}: {
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

    services.wpaperd = {
      enable = true;
      settings = {
        # "eDP-1" = {
        #   path = "${config.home.homeDirectory}/.nixos/dotfiles/wallpapers/laptop-wall.png";
        # };
        default = {
          path = ../../wallpapers/ufo-3840x2160.jpg;
        };
      };
    };

    # User packages
    home.packages = with pkgs; [
      # System & UI
      ghostty
      waybar
      swww
      vicinae
      bluetuith
      grim
      slurp
      hyprpolkitagent
      swaynotificationcenter

      # CLI utils
      fd
      wl-clipboard

      # Applications
      zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      google-chrome
      discord
      nordpass
      pavucontrol
      yazi
    ];
  };
}
