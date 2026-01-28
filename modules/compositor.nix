# Personal machine configuration (GUI + personal services)
{pkgs, ...}: {
  imports = [
    ./home/compositor.nix
    ./base.nix
    ./dev.nix
  ];

  config = {
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

    # Steam
    programs.steam = {
      enable = true;
      # Enable Gamescope (highly recommended for Wayland/Hyprland users)
      gamescopeSession.enable = true;
    };

    # Optional but recommended for gaming
    programs.gamemode.enable = true;
  };
}
