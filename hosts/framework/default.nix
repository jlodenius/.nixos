{
  self,
  inputs,
  ...
}: let
  system = "x86_64-linux";
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
        services.framework-control.enable = true;
        services.udev.extraRules = ''
          SUBSYSTEM=="power_supply", ACTION=="add|change|remove", ENV{POWER_SUPPLY_ONLINE}=="[01]", RUN+="${pkgs.systemd}/bin/systemctl --no-block restart framework-power-profile.service"
        '';
        systemd.services.framework-power-profile = {
          description = "Select the power profile based on charger connection";
          wantedBy = ["graphical.target"];
          requires = ["power-profiles-daemon.service"];
          after = ["power-profiles-daemon.service"];
          path = [pkgs.coreutils pkgs.systemd pkgs.power-profiles-daemon];
          serviceConfig = {
            Type = "oneshot";
            RuntimeDirectory = "framework-power-profile";
            RuntimeDirectoryMode = "0700";
            RuntimeDirectoryPreserve = "yes";
          };
          script = ''
            state_file="$RUNTIME_DIRECTORY/power-source"
            if systemd-ac-power; then
              power_source=ac
              profile=performance
            else
              status=$?
              if [[ "$status" != 1 ]]; then
                exit "$status"
              fi
              power_source=battery
              profile=balanced
            fi
            if [[ -f "$state_file" && "$(<"$state_file")" == "$power_source" ]]; then
              exit 0
            fi
            powerprofilesctl set "$profile"
            printf '%s\n' "$power_source" > "$state_file.next"
            mv "$state_file.next" "$state_file"
          '';
        };
        boot.kernelPackages = pkgs.linuxPackages_latest;
        hardware.intelgpu.driver = "xe";
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
