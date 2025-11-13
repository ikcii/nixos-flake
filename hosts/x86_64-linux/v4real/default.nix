# Host-specific settings for the 'v4real' desktop
{ ... }:

{
  
  imports = [
    ../../../profiles/desktop
    ../../../profiles/desktop/gaming
  ];

  # --- Graphics & NVIDIA PRIME Offload ---
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

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

  # Environment variables for PRIME render offload
  environment.sessionVariables = {
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
    GDM_BACKEND = "nvidia-drm";
  };

  # --- Virtualization ---
  virtualisation.docker.enable = true;
}
