{ ... }:

{
  
  imports = [
    ../../../profiles/desktop
    ../../../profiles/desktop/gaming
  ];

  services.logrotate.enable = false;

  # --- Virtualization ---
  virtualisation.docker.enable = true;
}
