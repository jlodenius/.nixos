# SIS work environment
{...}: {
  flake.nixosModules.sis = {...}: {
    security.pki.certificateFiles = [
      ./sd-api-ca.crt
    ];

    networking.hosts."127.0.0.1" = [
      "mol-dev.sis.se"
      "mol-admin-dev.sis.se"
      "dev-viewer.standard.sis.se"
      "sd-api.dev.sis.se"
    ];
  };
}
