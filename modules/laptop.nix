{...}: {
  flake.nixosModules.laptop = {pkgs, ...}: {
    # Lid close suspends (swayidle locks first via before-sleep); with an
    # external monitor attached, logind's HandleLidSwitchDocked=ignore applies.
    services.logind.settings.Login.HandleLidSwitch = "suspend";

    # Battery management
    services.upower = {
      enable = true;
      allowRiskyCriticalPowerAction = true;
      criticalPowerAction = "Suspend";
    };

    # Power button shortcuts
    services.logind.settings.Login.HandlePowerKey = "suspend-then-hibernate";
    services.logind.settings.Login.HandlePowerKeyLongPress = "poweroff";

    # Thunderbolt device manager (boltctl + auto-authorization)
    services.hardware.bolt.enable = true;

    environment.systemPackages = with pkgs; [
      brightnessctl
    ];
  };
}
