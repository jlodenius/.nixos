#
# Develop wayland apps in Rust using `wayland_client` and `smithay_client_toolkit`
#
{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "wayland-dev-shell";

  # Packages that run on the computer during the build process
  # Automatically added to $PATH
  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  # Packages that the program links against or uses at runtime
  # Automatically added to compiler flags (like NIX_CFLAGS_COMPILE) and PKG_CONFIG_PATH
  buildInputs = with pkgs; [
    libxkbcommon
  ];
}
