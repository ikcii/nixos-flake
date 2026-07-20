{ ... }:
{
  extraGroups = [
    "networkmanager"
    "wheel"
    "video"
  ];

  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsNjN0MQ1O+D96fOK6JC/G/3cPSNRIM0WeaRFK1u+Gr"
  ];
}
