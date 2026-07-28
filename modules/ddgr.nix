{...}: {
  flake.nixosModules.ddgr = {pkgs, ...}: {
    environment.systemPackages = [pkgs.ddgr];
  };
}
