{ ... }: {
	imports = [ ../../users/modules/host-users.nix ];

	programs.steam.enable = true;
	programs.gamemode.enable = true;
}
