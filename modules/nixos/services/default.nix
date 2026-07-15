{ lib, pkgs, ... }:

{
  # ZeroTier
  services.zerotierone.enable = true;

  # Encrypted DNS
  networking.networkmanager.dns = "none";
  networking.nameservers = [
    "127.0.0.1"
    "::1"
  ];
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [
          "127.0.0.1"
          "::1"
        ];
        access-control = [
          "127.0.0.0/8 allow"
          "::1/128 allow"
        ];

        hide-identity = "yes";
        hide-version = "yes";
      };

      forward-zone =
        let
          mkMullvadRegularEntry = domainName: {
            name = domainName;
            forward-addr = [
              "194.242.2.2@853#dns.mullvad.net"
              "2a07:e340::2@853#dns.mullvad.net"
            ];
            forward-tls-upstream = "yes";
          };
        in
        [
          # Arma
          (mkMullvadRegularEntry "bohemia.net")
          (mkMullvadRegularEntry "armaplatform.com")
          (mkMullvadRegularEntry "bistudio.com")

          # Global
          {
            name = ".";
            forward-addr = [
              "194.242.2.4@853#base.dns.mullvad.net"
              "2a07:e340::4@853#base.dns.mullvad.net"
            ];
            forward-tls-upstream = "yes";
          }
        ];
    };
  };
}
