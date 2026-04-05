# NixOS

## Setup

This repo must be cloned to `~/.nixos` — several modules use symlinks that depend on this path.

```sh
git clone git@github.com:jlodenius/nixos.git ~/.nixos
```

## Packages

Standalone packages that can be run independently from anywhere

### Neovim

```sh
nix run --extra-experimental-features "nix-command flakes" github:jlodenius/nixos#neovim
```
