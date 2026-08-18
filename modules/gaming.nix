{...}: {
  flake.nixosModules.gaming = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      instawow
      lutris
    ];

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    programs.gamemode.enable = true;
  };
}
