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

  # Run unpatched binaries
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    nss
    nspr
    glib
    dbus
    atk
    at-spi2-atk
    libdrm
    expat
    libxcb
    libxkbcommon
    at-spi2-core
    alsa-lib
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXrandr
    mesa
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
