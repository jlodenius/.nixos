# Development environment
{pkgs, ...}: {
  imports = [
    ./home/dev.nix
  ];

  # SIS Dev
  networking.hosts = {
    "127.0.0.1" = [
      "mol-dev.sis.se"
      "mol-admin-dev.sis.se"
      "dev-viewer.standard.sis.se"
    ];
  };

  # Docker
  virtualisation.docker.enable = true;
  users.users.jacob.extraGroups = ["docker"];

  # Enable nix-ld
  programs.nix-ld.enable = true;

  # Define the libraries available to unpatched binaries
  programs.nix-ld.libraries = with pkgs; [
    glib
    nss
    nspr
    dbus
    atk
    at-spi2-atk
    cups
    libdrm
    expat
    libxcb
    libxkbcommon
    at-spi2-core
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    mesa
    pango
    cairo
    udev
    alsa-lib

    # --- Essentials for most binaries ---
    stdenv.cc.cc
    zlib
    openssl
  ];

  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    cmake
    cpuset
    gdb
    lldb
    mkcert
    nodejs
    pnpm

    # Rust
    rustup
    cargo-expand
    cargo-hack
    cargo-insta
    cargo-machete
    cargo-msrv
    cargo-nextest
    cargo-outdated
  ];
}
