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
  flake.nixosConfigurations.framework = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    modules = [
      # Hardware
      inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
      ./hardware-configuration.nix

      # Features
      self.nixosModules.base
      self.nixosModules.laptop
      self.nixosModules.dev
      self.nixosModules.claude
      self.nixosModules.pi
      self.nixosModules.sis
      self.nixosModules.fish
      self.nixosModules.xkb
      self.nixosModules.desktop
      self.nixosModules.nordvpn
      self.nixosModules.gaming
      self.nixosModules.niri
      self.nixosModules.colours
      self.nixosModules.quickshell
      self.nixosModules.ghostty
      self.nixosModules.yazi
      self.nixosModules.tmux
      self.nixosModules.helium
      self.nixosModules.mlqs

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
      ({pkgs, ...}: {
        networking.hostName = "framework";
        boot.kernelPackages = pkgs.unstable.linuxPackages_latest;
        hardware.intelgpu.driver = "xe";
        boot.extraModprobeConfig = "options iwlwifi disable_11be=1"; # Temporarily disable Wi-Fi 7 due to connection interruptions on the Deco mesh.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        networking.firewall.enable = false;

        # Note:
        # Set these once at install time, never change. Ensures backwards compatibility
        # when NixOS/home-manager modules change defaults between releases.
        system.stateVersion = "26.05";
        home-manager.users.jacob.home.stateVersion = "26.05";
      })
    ];
  };
}
