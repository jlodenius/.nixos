# Desktop environment — system and user config in one place
{inputs, ...}: {
  flake.nixosModules.compositor = {pkgs, ...}: {
    # Graphics
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # Critical for Steam
    };

    # Bluetooth
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      package = pkgs.bluez5-experimental; # Good for the latest codec support
      settings = {
        Policy = {
          AutoEnable = true;
        };
      };
    };

    # Audio
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      wireplumber = {
        enable = true;
        extraConfig = {
          "10-bluez" = {
            "monitor.bluez.properties" = {
              "bluez5.enable-sbc-xq" = true;
              "bluez5.enable-msbc" = true;
              "bluez5.enable-hw-volume" = true;
              "bluez5.codecs" = ["sbc" "sbc_xq" "aac" "ldac" "aptx" "aptx_hd" "cvsd" "msbc" "lc3"];
              "bluez5.roles" = ["hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag"];
            };
          };
        };
      };
    };

    # Keyboard layout
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Hyprland
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };

    # Screen sharing
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = ["hyprland" "gtk"];
        };
      };
    };

    # Fonts
    fonts.packages = with pkgs; [
      nerd-fonts.geist-mono
    ];

    programs.dconf.enable = true;

    # Security for GUI session
    services.gnome.gnome-keyring.enable = true;
    security.polkit.enable = true;
    security.pam.services.swaylock = {};

    # Enable kernel keyring for login sessions (needed for bitwarden CLI session caching)
    security.pam.services.login.enableGnomeKeyring = true;
    security.pam.services.login.rules.session.keyinit = {
      order = 5000;
      control = "optional";
      modulePath = "pam_keyinit.so";
      args = ["force" "revoke"];
    };

    # Steam
    programs.steam = {
      enable = true;
      # Enable Gamescope (highly recommended for Wayland/Hyprland users)
      gamescopeSession.enable = true;
    };

    # Optional but recommended for gaming
    programs.gamemode.enable = true;

    # ── User-level desktop config ──────────────────────────────────────

    home-manager.users.jacob = {
      config,
      pkgs,
      ...
    }: {
      home.stateVersion = "25.11";

      home.sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        GTK_THEME = "Adwaita:dark";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_CURRENT_DESKTOP = "Hyprland";
        BROWSER = "qutebrowser";
      };

      # Default applications
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "org.qutebrowser.qutebrowser.desktop";
          "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
          "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";
          "x-scheme-handler/about" = "org.qutebrowser.qutebrowser.desktop";
          "x-scheme-handler/unknown" = "org.qutebrowser.qutebrowser.desktop";
        };
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
        wofi
        keyutils
        unzip

        # Applications
        inputs.stockfin.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        qutebrowser
        google-chrome
        discord
        slack
        teams-for-linux
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
          pinentry = pkgs.pinentry-qt;
        };
      };
    };
  };
}
