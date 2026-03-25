{...}: {
  flake.nixosModules.niri = {pkgs, ...}: {
    programs.niri.enable = true;

    environment.systemPackages = with pkgs; [
      xwayland-satellite
    ];

    home-manager.users.jacob = {config, ...}: {
      xdg.configFile."niri".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/dotfiles/niri";
    };
  };
}
