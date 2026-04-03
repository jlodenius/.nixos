{...}: {
  flake.nixosModules.symlinks = {...}: {
    home-manager.users.jacob = {config, ...}: let
      dotfilesPath = "${config.home.homeDirectory}/.nixos/dotfiles";
    in {
      xdg.configFile = {
        "ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ghostty";
        "waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/waybar";
        "yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/yazi";
        "qutebrowser".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/qutebrowser";
      };
    };
  };
}
