{...}: {
  flake.nixosModules.symlinks = {...}: {
    home-manager.users.jacob = {config, ...}: let
      dotfilesPath = "${config.home.homeDirectory}/.nixos/dotfiles";
    in {
      xdg.configFile = {
        "qutebrowser".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/qutebrowser";
      };
    };
  };
}
