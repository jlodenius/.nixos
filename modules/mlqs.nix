{inputs, ...}: {
  # mlqs — native Gmail/Outlook client (Go daemon + Quickshell/QML UI).
  # Upstream: github:daphen/mlqs
  #
  # ── What THIS module manages (declarative, in the repo) ──────────────
  #   • packages: mlqs-client (launcher, spawns the daemon) + mlqs (CLI/daemon,
  #     needed for the `mlqs auth` bootstrap below)
  #   • ~/.config/mlqs/accounts.json  — generated from the account list here
  #
  # ── What you MUST set up by hand on each new machine (NOT in nix) ─────
  #   These hold a secret / mutable runtime state, so they live outside the
  #   read-only nix store. accounts.json above points at (1).
  #
  #   1. ~/.config/mlqs/google.json   (chmod 600)
  #      Google Cloud OAuth *desktop app* client JSON. Shape: {"installed":{…}}.
  #      Reusable across machines. To create it (once per Google project):
  #        console.cloud.google.com → new project → enable Gmail API
  #        → OAuth consent screen: External, **publish to production**
  #          (skipping this expires tokens weekly)
  #        → Credentials → OAuth client ID → Desktop app → download JSON
  #      See the upstream README section "Google OAuth" for the full walkthrough.
  #
  #   2. Authorize the account (opens a browser consent tab):
  #        mlqs auth gmail
  #      Writes ~/.local/share/mlqs/tokens/gmail.json. The daemon refreshes
  #      and rewrites this file at runtime — that's why it can't be nix-managed.
  #
  # ── Pure runtime, ignore (regenerable cache) ─────────────────────────
  #   ~/.local/share/mlqs/cache.db*   ~/.cache/mlqs/*
  #
  # ── New-machine bootstrap, in order ──────────────────────────────────
  #   rebuild  →  drop in google.json (step 1)  →  `mlqs auth gmail`  →  done
  flake.nixosModules.mlqs = {pkgs, ...}: {
    environment.systemPackages = let
      inherit (pkgs.stdenv.hostPlatform) system;
    in [
      inputs.mlqs.packages.${system}.mlqs-client
      inputs.mlqs.packages.${system}.mlqs
    ];

    home-manager.users.jacob = {config, ...}: {
      xdg.configFile."mlqs/accounts.json".text = builtins.toJSON {
        accounts = [
          {
            name = "gmail";
            vendor = "gmail";
            email = "jacoblodenius@gmail.com";
            credentials_file = "${config.home.homeDirectory}/.config/mlqs/google.json";
          }
        ];
      };
    };
  };
}
