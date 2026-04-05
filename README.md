# NixOS

## Setup

This repo must be cloned directly into the home directory as `~/.nixos`:

```sh
git clone git@github.com:jlodenius/nixos.git ~/.nixos
```

Several modules use symlinks that reference this exact path.

## Run packaged neovim from anywhere

```sh
nix run --extra-experimental-features "nix-command flakes" github:jlodenius/nixos#neovim
```
