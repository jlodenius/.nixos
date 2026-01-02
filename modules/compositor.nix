# Personal machine configuration (GUI + personal services)
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./home/compositor.nix
    ./base.nix
    ./audio.nix
  ];

  config = {
    # Graphics (extraPackages are host-specific)
    hardware.graphics.enable = true;

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
      extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
      config = {
        common = {
          default = "wlr";
        };
      };
      wlr.enable = true;
      wlr.settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
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

    # Enable nix-ld to run unpatched binaries (like Node from nvm)
    programs.nix-ld.enable = true;

    # List the libraries that these binaries usually expect to find
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      nss
      openssl
      curl
      expat
    ];
  };
}
