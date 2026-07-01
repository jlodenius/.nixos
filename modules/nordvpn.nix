# NordVPN over WireGuard via wgnord. Self-contained — add/remove
# `self.nixosModules.nordvpn` in a host to pull it in or out.
# Ref: https://kenshin.ninja/p/wgnord-nixos-nordvpn/
#
# Usage after rebuild:
#   sudo wgnord l "<token>"   # login with a NordVPN access token
#   sudo wgnord c sweden      # connect to a location
#   sudo wgnord d             # disconnect
{...}: {
  flake.nixosModules.nordvpn = {pkgs, ...}: {
    # System-level so `sudo wgnord` reliably finds the binaries.
    environment.systemPackages = with pkgs; [
      openresolv
      wireguard-tools
      wgnord
    ];

    # Create wgnord's state dirs and template declaratively instead of by hand.
    # template.conf is symlinked to the Nix store so it stays in sync with config.
    systemd.tmpfiles.rules = let
      template = pkgs.writeText "wgnord-template.conf" ''
        [Interface]
        PrivateKey = PRIVKEY
        Address = 10.5.0.2/32
        MTU = 1350
        DNS = 103.86.96.100 103.86.99.100

        [Peer]
        PublicKey = SERVER_PUBKEY
        AllowedIPs = 0.0.0.0/0, ::/0
        Endpoint = SERVER_IP:51820
        PersistentKeepalive = 25
      '';
    in [
      "d /etc/wireguard 0700 root root -"
      "d /var/lib/wgnord 0700 root root -"
      "L+ /var/lib/wgnord/template.conf - - - - ${template}"
    ];
  };
}
