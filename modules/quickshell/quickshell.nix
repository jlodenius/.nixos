{...}: {
  flake.nixosModules.quickshell = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      quickshell
      libnotify # notify-send; the daemon is quickshell's NotificationServer
    ];

    home-manager.users.jacob = {config, ...}: {
      xdg.configFile."quickshell".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/modules/quickshell/config";
    };
  };
}
