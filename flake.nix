{
	description = "My system flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
    		};

		stylix = {
			url = "github:danth/stylix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
  	};

	outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs: 
	let
		commonUsers = [ "ikci" ];

		hostData = {
			"v4real" = {
				system = "x86_64-linux";
				# hostSpecificUsers = [];
			};
		};

		myHosts = nixpkgs.lib.mapAttrs (hostname: config: 
			config
			// {
				users = commonUsers ++ (config.hostSpecificUsers or []);
			}
		) hostData;

		mkSystem = { hostname, system, users, ... }:
			nixpkgs.lib.nixosSystem {
				inherit system;
      				specialArgs = { inherit inputs users; };
      				modules = [
					({ config, ... }: 
					{
						networking.hostName = hostname;
						networking.dhcpcd.setHostname = false;
					})
      					./hosts/common/default.nix
					./hosts/${hostname}/hardware-configuration.nix

					./users/default.nix

					home-manager.nixosModules.home-manager
      				] ++ (nixpkgs.lib.optional (builtins.pathExists ./hosts/${hostname}/default.nix) ./hosts/${hostname}/default.nix);
			};
	in
	{
		nixosConfigurations = nixpkgs.lib.mapAttrs
			(hostname: config: mkSystem (config // { inherit hostname; }))
			myHosts;
	};
}
