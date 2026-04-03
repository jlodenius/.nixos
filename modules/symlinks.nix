{...}: {
  flake.nixosModules.symlinks = {...}: {
    home-manager.users.jacob = {config, ...}: let
      dotfilesPath = "${config.home.homeDirectory}/.nixos/dotfiles";
    in {
      xdg.configFile = {
        "waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/waybar";
        "qutebrowser".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/qutebrowser";
      };
    };
  };
}
