{...}: {
  flake.nixosModules.gaming = {pkgs, ...}: let
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
  };
}
