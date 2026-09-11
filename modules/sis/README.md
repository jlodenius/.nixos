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

Gateway-provided DNS remains enabled; this is not domain-specific split DNS.
The `/etc/ppp/ip-up` hook ignores connections without `pppd-ipparam = sis`,
but another module cannot independently replace the same hook.
