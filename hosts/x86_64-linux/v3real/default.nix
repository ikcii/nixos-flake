{ ... }:

{
  
  imports = [
    ../../../profiles/desktop
    ../../../profiles/desktop/gaming
  ];

  services.logrotate.enable = false;

  # --- Virtualization ---
  virtualisation.docker.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32*1024;
  }];
}
