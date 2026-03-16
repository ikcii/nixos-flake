# Host-specific settings for the 'v4real' desktop
{ ... }:

{

  imports = [
    ../../../profiles/desktop
    ../../../profiles/desktop/gaming
    ./disko.nix
  ];

  # --- Graphics & NVIDIA PRIME Offload ---
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.bluetooth.enable = true;

  services.blueman.enable = true;

  # --- Virtualization ---
  virtualisation.docker.enable = true;
}
