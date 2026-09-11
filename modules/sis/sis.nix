{...}: {
  flake.nixosModules.sis = {pkgs, ...}: let
    vpn-routes = [
      "172.16.0.0/16"
      # Azure SQL Sweden Central gateways (Proxy policy); see README.md.
      "51.12.46.32/27"
      "51.12.96.32/29"
      "51.12.224.32/29"
      "51.12.232.32/29"
    ];

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
    roslyn-ls-wrapped = pkgs.writeShellScriptBin "roslyn-language-server" ''
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

    environment.shellAliases.sisvpn = "sudo openfortivpn --saml-login";

    environment.etc."openfortivpn/config" = {
      mode = "0600";
      text = ''
        host = vpn-sis.it-total.se
        set-routes = 0
        pppd-ipparam = sis
      '';
    };

    systemd.tmpfiles.rules = [
      "d /etc/openfortivpn 0700 root root -"
    ];

    environment.etc."ppp/ip-up" = {
      mode = "0755";
      text = ''
        #!${pkgs.runtimeShell}
        set -eu
        if [ "''${6-}" != "sis" ]; then
          exit 0
        fi
        if [ -z "''${1-}" ]; then
          exit 1
        fi
        routes=(${pkgs.lib.escapeShellArgs vpn-routes})
        for route in "''${routes[@]}"; do
          ${pkgs.iproute2}/bin/ip route add "$route" dev "$1"
        done
      '';
    };

    environment.sessionVariables.DOTNET_ROOT = "${dotnet-wrapped}/share/dotnet";

    environment.systemPackages = [
      dotnet-wrapped
      roslyn-ls-wrapped
      pkgs.libsecret
      pkgs.azure-cli
      pkgs.azuredatastudio
      pkgs.openfortivpn
    ];
  };
}
