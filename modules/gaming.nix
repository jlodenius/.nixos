{...}: {
  flake.nixosModules.gaming = {pkgs, ...}: let
    xremap = pkgs.xremap.override {withVariant = "niri";};
    dota2KeySwap = (pkgs.formats.yaml {}).generate "dota2-key-swap.yml" {
      modmap = [
        {
          name = "Swap left Super and Alt only in Dota 2";
          application.only = ["dota2"];
          remap = {
            # The custom XKB layout uses left Alt as AltGr; right Alt supplies real Alt.
            KEY_LEFTMETA = "KEY_RIGHTALT";
            KEY_LEFTALT = "KEY_LEFTMETA";
          };
        }
      ];
    };
    pname = "wowup-cf";
    # Forever support is only in the 2.24 beta, not the current Nixpkgs release.
    version = "2.24.0-beta.6";
    src = pkgs.fetchurl {
      url = "https://github.com/WowUp/WowUp.CF/releases/download/v${version}/WowUp-CF-${version}.AppImage";
      hash = "sha256-TZ5b/DfVkEh9MsrBi2M/0dAPE1Tfd+zzquRXwprtLqQ=";
    };
    appimageContents = pkgs.appimageTools.extract {inherit pname version src;};
    wowup = pkgs.appimageTools.wrapType2 {
      inherit pname version src;
      extraInstallCommands = ''
        install -Dm444 ${appimageContents}/${pname}.desktop $out/share/applications/${pname}.desktop
        substituteInPlace $out/share/applications/${pname}.desktop \
          --replace-fail 'Exec=AppRun' 'Exec=${pname}'
        cp -r ${appimageContents}/usr/share/icons $out/share
      '';
      meta = pkgs.wowup-cf.meta;
    };
  in {
    environment.systemPackages = [wowup pkgs.lutris];

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    programs.gamemode.enable = true;

    hardware.uinput.enable = true;
    users.users.jacob.extraGroups = ["input" "uinput"];

    home-manager.users.jacob = {
      home.packages = [xremap];
      xdg.configFile."xremap/dota2.yml".source = dota2KeySwap;

      systemd.user.services.dota2-key-swap = {
        Unit = {
          Description = "Swap left Super and Alt while Dota 2 is focused";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
          ConditionEnvironment = "NIRI_SOCKET";
        };
        Service = {
          ExecStart = "${xremap}/bin/xremap --watch=device --no-window-logging --allow-launch=false ${dota2KeySwap}";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
