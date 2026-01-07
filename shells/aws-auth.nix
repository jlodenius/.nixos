{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = with pkgs; [
    # Everything needed for the browser to run
    mesa
    cups
    libgbm
    pango
    cairo

    # AWS Auth tools
    aws-vault
    saml2aws
    awscli2
  ];

  PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = 1;
}
