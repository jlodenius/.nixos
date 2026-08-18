{...}: {
  flake.nixosModules.gaming = {pkgs, ...}: {
    environment.systemPackages = [pkgs.lutris];

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    programs.gamemode.enable = true;
  };
}
