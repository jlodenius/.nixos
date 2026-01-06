# Development environment
{pkgs, ...}: {
  imports = [
    ./home/dev.nix
  ];

  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    cmake
    cpuset
    gdb
    lldb
    nodejs

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
