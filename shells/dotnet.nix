#
# .NET development shell
#
{pkgs ? import <nixpkgs> {config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) ["azuredatastudio"];}}:
pkgs.mkShell {
  name = "dotnet-dev-shell";

  packages = with pkgs; [
    (dotnetCorePackages.combinePackages [
      dotnetCorePackages.sdk_8_0
      dotnetCorePackages.sdk_9_0
    ])
    azure-cli
    azuredatastudio
    icu
    openssl
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.icu}/lib:${pkgs.openssl}/lib:$LD_LIBRARY_PATH
  '';
}
