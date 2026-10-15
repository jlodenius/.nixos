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
      "${inputs.nixpkgs-unstable}/nixos/modules/services/hardware/framework-control.nix"
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
        services.framework-control = {
          enable = true;
          package = pkgs.unstable.framework-control;
        };
        services.udev.extraRules = ''
          SUBSYSTEM=="power_supply", ACTION=="add|change|remove", ENV{POWER_SUPPLY_ONLINE}=="[01]", RUN+="${pkgs.systemd}/bin/systemctl --no-block restart framework-power-profile.service"
        '';
        systemd.services.framework-power-profile = {
          description = "Select the power profile based on charger connection";
          wantedBy = ["multi-user.target"];
          requires = ["power-profiles-daemon.service"];
          after = ["power-profiles-daemon.service"];
          path = [pkgs.systemd pkgs.power-profiles-daemon];
          serviceConfig.Type = "oneshot";
          script = ''
            if systemd-ac-power; then
              profile=performance
            else
              profile=balanced
            fi
            powerprofilesctl set "$profile"
          '';
        };
        boot.kernelPackages = pkgs.unstable.linuxPackages_latest;
        hardware.intelgpu.driver = "xe";
        hardware.graphics = {
          package = pkgs.unstable.mesa;
          package32 = pkgs.unstable.pkgsi686Linux.mesa;
        };
        services.xserver.videoDrivers = [
          # Disabled until https://github.com/NixOS/nixpkgs/issues/281104 is fixed. Its sleep hook hangs without the dock.
          # "displaylink"
          "modesetting"
          "fbdev"
        ];
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
