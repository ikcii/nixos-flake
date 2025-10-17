{ config, lib, pkgs, ... }:

let

	activeUsers = config.users.common ++ config.users.hostSpecific;
	
	generateUsersConfig = users: {
		users.users = lib.listToAttrs (map (username: {
			name = username;
			value = (import ./accounts/${username}/user.nix) { inherit pkgs; };
		}) users);


		home-manager.users = lib.listToAttrs (map (username: {
			name = username;
			value = import ./accounts/${username}/home.nix;
		}) users);
	};

in

generateUsersConfig activeUsers
