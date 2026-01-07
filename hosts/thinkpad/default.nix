# Host configuration for thinkpad
{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/compositor.nix
    ../../modules/laptop.nix
  ];

  networking.hostName = "thinkpad";

  # Boot configuration (may differ between hosts)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Firewall
  networking.firewall.enable = false;
}
