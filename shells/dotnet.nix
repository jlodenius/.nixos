#
# .NET development shell
#
{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "dotnet-dev-shell";

  packages = with pkgs; [
    dotnetCorePackages.sdk_8_0
    azure-cli
    icu
    openssl
  ];

  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.icu}/lib:${pkgs.openssl}/lib:$LD_LIBRARY_PATH
    export ConnectionStrings__DefaultConnection="Server=localhost,1433;Database=SubscriptionDelivery;User Id=sa;Password=Localhost1!;TrustServerCertificate=True"
  '';
}
