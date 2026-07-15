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
  #   2. Authorize each account (opens a browser consent tab):
  #        mlqs auth gmail        # Gmail  (needs google.json from step 1)
  #        mlqs auth sis          # Outlook (client_id is in accounts.json — no
  #                               #  google.json; the SIS app reg is "jacob-test")
  #      Writes ~/.local/share/mlqs/tokens/<name>.json. The daemon refreshes
  #      and rewrites these at runtime — that's why they can't be nix-managed.
  #
  # ── Pure runtime, ignore (regenerable cache) ─────────────────────────
  #   ~/.local/share/mlqs/cache.db*   ~/.cache/mlqs/*
  #
  # ── New-machine bootstrap, in order ──────────────────────────────────
  #   rebuild  →  google.json (step 1)  →  `mlqs auth gmail` + `mlqs auth sis`
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
          {
            # Outlook uses a public PKCE client_id (not a secret) — safe to keep
            # here in plaintext. App registration "jacob-test" in the SIS tenant.
            name = "sis";
            vendor = "outlook";
            email = "jacob.lodenius@sis.se";
            client_id = "122131d3-4fe7-4ca7-9853-c920caf4a60f";
          }
        ];
      };
    };
  };
}
