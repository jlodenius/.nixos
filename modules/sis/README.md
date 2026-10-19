# SIS VPN

Based on [SIS VPN on NixOS](https://gist.github.com/marsa099/4553580ba62dfd8717cacf96ee416570).
Both hosts already import `sis.nix`.

## Connect

Apply the configuration (use `thinkpad` instead of `framework` on that host):

```sh
sudo nixos-rebuild switch --flake ~/.nixos#framework
```

Open a new terminal to load the alias, then connect:

```sh
sisvpn
```

This runs `sudo openfortivpn --saml-login` in the foreground.
Open the printed URL in this computer's browser and complete Microsoft login/MFA.
Wait for `Tunnel is up and running`. Press **Ctrl+C** to disconnect.
Reconnect after changing the route hook.

The module manages `/etc/openfortivpn/config` as root-only (`0600`, directory
`0700`). It contains no credentials. Do not add passwords or tokens to the Nix
configuration: its contents are readable in the Nix store.

## Routing and verification

The VPN explicitly routes `172.16.0.0/16` and the Azure SQL gateway ranges
listed below. `172.16.0.0/16` is the gist's selected SIS range, not a confirmed
inventory of every SIS network or the VPN gateway's requested routing policy.
Check for local subnet conflicts and ensure this split-tunnel policy is
permitted by SIS. Other traffic retains its
existing routes. Avoid running another VPN during initial testing.

While connected:

```sh
ip route show exact 172.16.0.0/16
ip route get 172.16.32.4
getent ahostsv4 pm.sis.se
getent ahostsv4 intra.sis.se
```

The route should use the active PPP interface. Open <https://pm.sis.se> and
<https://intra.sis.se> to verify access. After disconnecting, the SIS route
should disappear.

## Azure SQL: SIS databases

These server hostnames currently resolve publicly to Azure SQL Sweden Central
gateways, already covered by `51.12.46.32/27`:

- `sqls-contentdelivery-dev.database.windows.net`
- `sqls-cloudstorage-sis-prd.database.windows.net`
- `sqls-contentdelivery-tst.database.windows.net`
- `sql-api-sis-tst.database.windows.net`
- `sql-api-sis-prd.database.windows.net`
- `sqls-contentdelivery-prd.database.windows.net`

Keep the existing server values unchanged in Azure Data Studio, including any
`tcp:` prefix and `,1433` port suffix. Those are connection settings, not part
of an IP route. For example:

```text
tcp:sqls-contentdelivery-dev.database.windows.net,1433
```

`vpn-routes` includes all four Sweden Central gateway ranges published in
[Microsoft's connectivity documentation](https://learn.microsoft.com/en-us/azure/azure-sql/database/connectivity-architecture?view=azuresql#gateway-ip-addresses),
rather than pinning one DNS result. These shared ranges also route connections
to other Azure SQL servers using those gateways, on any port.

This covers **Proxy** connectivity, the default for clients outside Azure.
An explicitly configured **Redirect** policy can use additional destination
addresses and ports; these gateway routes alone are not sufficient for it.
A private endpoint may instead resolve to a private IP when using SIS DNS.
Servers in other Azure regions need their own confirmed routes, and published
gateway ranges can change over time.

After connecting, check `getent ahostsv4 sqls-contentdelivery-dev.database.windows.net`
and `ip route get <resolved-ip>`, then connect using Azure Data Studio. A route
alone does not establish that the SIS gateway permits or provides outbound
access to Azure, or that the SQL firewall accepts its public egress address.

## Additional routes (including databases)

Edit `vpn-routes` at the top of `modules/sis/sis.nix`. Use an IPv4 address with
`/32` for one server, or a CIDR subnet for a whole network. Append entries to
the existing list, keeping the Azure gateway routes if needed. This shortened
example uses illustrative additional addresses only:

```nix
vpn-routes = [
  "172.16.0.0/16"
  "10.20.30.40/32"
  "10.50.0.0/24"
];
```

Do not add these example ranges unless they are actually yours. Databases
already within `172.16.0.0/16` need no extra route. To look up a database's IPv4
addresses while connected:

```sh
getent ahostsv4 your-database-hostname
```

Use IP/CIDR entries in the list, not hostnames. Include all required addresses;
if DNS changes them, these static routes must be updated. Prefer a confirmed
SIS subnet when appropriate, but avoid overly broad ranges or `0.0.0.0/0`.
A route only helps if the VPN gateway permits access to that network.

Rebuild, disconnect with **Ctrl+C**, then reconnect with `sisvpn` to apply the
new routes. Check `ip route get <database-ip>` for the PPP interface and test
the database connection with your usual client. Every listed route is removed
when the PPP interface disappears.

## DNS

Gateway-provided DNS remains enabled; this is not domain-specific split DNS.
The VPN is built to use the same `openresolv` manager as NetworkManager, with
`use-resolvconf = 1` and `pppd-use-peerdns = 0` so only that manager writes
`/etc/resolv.conf`.

The default VPN package detects systemd's `resolvconf` compatibility tool at
build time and disables managed DNS by default. Its direct file edits cause
openresolv to reject Wi-Fi DNS updates with `signature mismatch`. After moving
to another Wi-Fi network, disconnecting the VPN can therefore leave the old
network's DNS behind until Wi-Fi reconnects. Sharing openresolv lets VPN
cleanup regenerate DNS using NetworkManager's current settings instead.

After rebuilding, start a new `sisvpn` process to use the fixed package. If DNS
is already stale, disconnect the old VPN first, then run `sudo resolvconf -u`.
Verify that `/etc/resolv.conf` contains the current Wi-Fi DNS after disconnecting
the VPN, including after moving between networks.

The `/etc/ppp/ip-up` hook ignores connections without `pppd-ipparam = sis`,
but another module cannot independently replace the same hook.

## .NET and Azure Artifacts authentication

`sis.nix` installs `pkgs.azure-artifacts-credprovider` from the pinned nixpkgs revision. NuGet loads
its managed DLL through the current SDK host, selected by `NUGET_NETCORE_PLUGIN_PATHS`. The system
`dotnet` wrapper sets this variable too, so an existing terminal uses the correct provider
after switching. Explicit discovery excludes the mutable global-tool launchers on `PATH`.

Home Manager also owns `~/.dotnet/tools/nuget-plugin-microsoft-artifacts-credential-provider` as a
symlink to the Nix package's launcher, which uses its own compatible .NET runtime. On first
activation, the old executable moves to `~/.local/state/nuget-credential-provider/legacy-launcher`.
Repeated migrations preserve older backups with numbered suffixes. Backups must stay outside
`~/.dotnet/tools`: NuGet can discover executable `nuget-plugin-*.backup` files there too.

This avoids a patched global tool retaining an old glibc interpreter/RUNPATH while loading a newly
upgraded .NET runtime. Do not reinstall or patch this launcher with `dotnet tool install/update` or
`patchelf`; update nixpkgs and rebuild instead. The old tool's `.store` payload is left alone.
Provider versions follow nixpkgs (currently 2.0.1), not the previous mutable installation (2.0.4).
Authentication, token caches, private-feed configuration, and NuGet auditing are unchanged.

Build and run the isolated regression test before activating (Bash syntax):

```bash
config=.#nixosConfigurations.framework.config
system=$(nix build "$config.system.build.toplevel" --no-link --print-out-paths)
provider=$(nix eval --raw "$config.environment.sessionVariables.NUGET_NETCORE_PLUGIN_PATHS")
python3 modules/sis/tests/nuget-provider.py "$system/sw/bin/dotnet" "$provider"
```

The test uses a temporary home, a localhost-only HTTP 401 feed, and a deliberately broken launcher
first on `PATH`. It checks provider help, NuGet initialization and credential requests, and
exclusion of that launcher. Restore should fail with HTTP 401, never with GLIBC
or broken-pipe errors. It does not contact private feeds, use existing credentials,
or start application code.

Activate with the usual `sudo nixos-rebuild switch --flake ~/.nixos#framework` workflow. Start a new
login session for other SDKs/IDE processes to inherit the session variable, then verify:

```sh
dotnet "$NUGET_NETCORE_PLUGIN_PATHS" -h
~/.dotnet/tools/nuget-plugin-microsoft-artifacts-credential-provider -h
```

Both commands should print provider help without GLIBC errors. Private-feed restore still requires
normal Azure authentication; this test verifies plugin startup, not access to a real feed.
