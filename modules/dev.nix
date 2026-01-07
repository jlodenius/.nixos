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
