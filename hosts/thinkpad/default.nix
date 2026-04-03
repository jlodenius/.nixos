{
  self,
  inputs,
  ...
}: let
  system = "x86_64-linux";

  overlay-unstable = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };
in {
  flake.nixosConfigurations.thinkpad = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    modules = [
      # Hardware
      ./hardware-configuration.nix

      # Features
      self.nixosModules.base
      self.nixosModules.laptop
      self.nixosModules.dev
      self.nixosModules.sis
      self.nixosModules.fish
      self.nixosModules.dark-theme
      self.nixosModules.xkb
      self.nixosModules.desktop
      self.nixosModules.gaming
      self.nixosModules.hyprland
      self.nixosModules.niri
      self.nixosModules.colours
      self.nixosModules.swaync
      self.nixosModules.ghostty
      self.nixosModules.yazi
      self.nixosModules.tmux
      self.nixosModules.waybar
      self.nixosModules.qutebrowser

      # Unstable overlay
      ({...}: {nixpkgs.overlays = [overlay-unstable];})

      # Home Manager
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
      }

      # Host-specific config
      {
        networking.hostName = "thinkpad";
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        networking.firewall.enable = false;

        # Note:
        # Set these once at install time, never change. Ensures backwards compatibility
        # when NixOS/home-manager modules change defaults between releases.
        system.stateVersion = "25.11";
        home-manager.users.jacob.home.stateVersion = "25.11";
      }
    ];
  };
}
