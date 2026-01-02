{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./modules/audio.nix
    ./modules/laptop.nix
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";

  time.timeZone = "Europe/Stockholm";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  users.users.jacob = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "Jacob";
    extraGroups = ["wheel"];
    packages = with pkgs; [];
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.geist-mono
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  # Fish is configured in home.nix but has to be enabled here to use as default shell
  # for users
  programs.fish.enable = true;

  # Compositor also goes in configuration
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

  nixpkgs.config.allowUnfree = true;

  # Security for GUI session
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  security.pam.services.swaylock = {};

  system.stateVersion = "25.11";
  nix.settings.experimental-features = ["nix-command" "flakes"];
}
