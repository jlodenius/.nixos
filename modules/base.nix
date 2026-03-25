# Minimal system basics for ALL hosts
{inputs, ...}: {
  flake.nixosModules.base = {pkgs, ...}: {
    imports = [
      inputs.nix-index-database.nixosModules.nix-index
    ];

    # Run any nixpkgs program without installing
    programs.nix-index-database.comma.enable = true;

    nixpkgs.config.allowUnfree = true;

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Time and Locale
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

    # Users
    users.users.jacob = {
      shell = pkgs.fish;
      isNormalUser = true;
      extraGroups = ["wheel" "networkmanager"];
    };

    # NetworkManager for wifi & openvpn
    networking.networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };

    programs.fish.enable = true;

    environment.systemPackages = with pkgs; [
      vim
      htop
      openssh
      rsync
      wget
      nh
    ];
  };
}
