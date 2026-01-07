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
    # Basic system libs
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    nspr
    openssl
    curl
    expat

    # Graphics/Browser libs (Required for Playwright/Chromium)
    atk
    at-spi2-atk
    libdrm
    mesa
    libgbm
    pango
    cairo
    alsa-lib
    dbus
    glib
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
