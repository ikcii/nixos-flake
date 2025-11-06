{ ... }: {

	# users.list = [ "host-specific-user-username" ];

	services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

	virtualisation.docker.enable = true;

	programs.steam.enable = true;
	programs.gamemode.enable = true;

	#nvidia.acceptLicense = true;

	environment.sessionVariables = {
			__NV_PRIME_RENDER_OFFLOAD = "1";
			__NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
			__GLX_VENDOR_LIBRARY_NAME = "nvidia";
			__VK_LAYER_NV_optimus = "NVIDIA_only";
	};

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
}
