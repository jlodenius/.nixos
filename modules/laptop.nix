# Laptop-specific configuration (wifi, power, battery, lid)
{pkgs, ...}: {
  # NetworkManager for wifi
  networking.networkmanager.enable = true;
  users.users.jacob.extraGroups = ["networkmanager"];

  # Don't suspend just because I closed the lid
  services.logind.settings.Login.HandleLidSwitch = "ignore";

  # Battery management
  services.upower = {
    enable = true;
    allowRiskyCriticalPowerAction = true;
    criticalPowerAction = "Suspend";
  };

  # Power button shortcuts
  services.logind.settings.Login.HandlePowerKey = "suspend-then-hibernate";
  services.logind.settings.Login.HandlePowerKeyLongPress = "poweroff";

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
