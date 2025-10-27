{ ... }: {
	imports = [ ../../users/modules/host-users.nix ];

	# users.hostSpecific = [ "host-specific-user-username" ];

	services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

	programs.steam.enable = true;
	programs.gamemode.enable = true;

	#nvidia.acceptLicense = true;

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
