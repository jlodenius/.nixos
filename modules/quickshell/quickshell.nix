{...}: {
  flake.nixosModules.quickshell = {
    config,
    pkgs,
    ...
  }: let
    colours = config.colours;
  in {
    environment.systemPackages = with pkgs; [
      quickshell
      libnotify # notify-send; the daemon is quickshell's NotificationServer
      swayidle # drives the quickshell lock (idle timeout + before-sleep)
    ];

    # Auth backend for the quickshell lock screen (LockScreen.qml).
    security.pam.services.quickshell = {};

    home-manager.users.jacob = {config, ...}: {
      programs.quickshell = {
        enable = true;
        systemd.enable = true;
      };
      systemd.user.services.quickshell = {
        Unit.PartOf = ["graphical-session.target"];
        Service = {
          Environment = ["QT_QPA_PLATFORM=wayland"];
          RestartSec = 2;
        };
      };

      xdg.configFile."quickshell".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.nixos/modules/quickshell";

      # Palette single-source: colours.nix → JSON consumed by Theme.qml.
      xdg.dataFile."quickshell/colours.json".text = builtins.toJSON colours;
    };
  };
}
