{ ... }:
{
  extraGroups = [
    "networkmanager"
    "wheel"
    "video"
  ];

  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsNjN0MQ1O+D96fOK6JC/G/3cPSNRIM0WeaRFK1u+Gr"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5E5mFG15wRrNQ4h/2XfDRLVs4L85X02dnelGiQL2i4"
  ];
}
