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

    # Rust
    rustc
    rustfmt
    clippy
    cargo
    cargo-expand
    cargo-hack
    cargo-insta
    cargo-machete
    cargo-msrv
    cargo-nextest
    cargo-outdated
  ];

  # Enable nix-ld to run unpatched binaries (like Node from nvm)
  programs.nix-ld.enable = true;

  # List the libraries that these binaries usually expect to find
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
  ];
}
