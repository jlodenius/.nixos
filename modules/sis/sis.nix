{...}: {
  flake.nixosModules.sis = {pkgs, ...}: let
    dotnet-wrapped = pkgs.symlinkJoin {
      name = "dotnet-sdk-wrapped";
      paths = [pkgs.dotnet-sdk_10];
      nativeBuildInputs = [pkgs.makeBinaryWrapper];
      postBuild = ''
        rm "$out/bin/dotnet"
        makeBinaryWrapper "${pkgs.dotnet-sdk_10}/bin/dotnet" "$out/bin/dotnet" \
          --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [pkgs.libsecret pkgs.icu pkgs.openssl]}" \
          --set DOTNET_ROLL_FORWARD LatestMajor
      '';
    };

    # Run Roslyn LSP through system dotnet so it inherits the correct DOTNET_ROOT
    # and can find the SDK. The nixpkgs wrapper resolves paths incorrectly on NixOS.
    roslyn-ls-wrapped = pkgs.writeShellScriptBin "roslyn" ''
      exec "${dotnet-wrapped}/bin/dotnet" "${pkgs.unstable.roslyn-ls}/lib/roslyn-ls/Microsoft.CodeAnalysis.LanguageServer.dll" "$@"
    '';
  in {
    security.pki.certificateFiles = [
      ./sd-api-ca.crt
    ];

    networking.hosts."127.0.0.1" = [
      "mol-dev.sis.se"
      "mol-admin-dev.sis.se"
      "dev-viewer.standard.sis.se"
      "sd-api.dev.sis.se"
    ];

    environment.sessionVariables.DOTNET_ROOT = "${dotnet-wrapped}/share/dotnet";

    environment.systemPackages = [
      dotnet-wrapped
      roslyn-ls-wrapped
      pkgs.libsecret
      pkgs.azure-cli
      pkgs.azuredatastudio
    ];
  };
}
