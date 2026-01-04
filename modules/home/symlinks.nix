# Create symlinks for all dotfiles
{config, ...}: let
  dotfilesPath = "${config.home.homeDirectory}/.nixos/dotfiles";
in {
  # --- Files in ~/.config/ ---
  xdg.configFile = {
    "ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ghostty";
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hypr";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim";
    "swaync".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/swaync";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/waybar";
    "xkb".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/xkb";
    "yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/yazi";
  };

  # --- Files directly in ~/ ---
  # home.file = {
  #   ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux.conf";
  # };
}
