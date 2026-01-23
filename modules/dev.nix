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

  # Required to run unpatched bins (not in nix-store)
  #
  # TODO:
  # Remove if no longer necessary/clean up unused libs, not sure
  # if the ones currently listed are all necessary
  #
  # Used for:
  # 1. AWS auth with playwright
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    xorg.libX11
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrender
    xorg.libXtst
    xorg.libXrandr

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
    cups
    mesa
    libgbm
    pango
    cairo
    stdenv.cc.cc
    openssl
    zlib
  ];

  environment.systemPackages = with pkgs; [
    # Misc
    gcc
    gnumake
    cmake
    cpuset
    gdb
    glib
    lldb
    nodejs
    pnpm

    # Python
    (python3.withPackages (ps:
      with ps; [
        pip
        setuptools

        # Some caesari requirements
        pyzmq
        requests
        protobuf
      ]))
    uv

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
