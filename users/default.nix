{ lib, config, homeManagerModules, ... }:

{
  options.users.list = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "A list of all user accounts to be created on this system.";
  };

  config = {
    users.users = lib.listToAttrs (map (username: {
      name = username;
      value = import ./${username};
    }) config.users.list);

    home-manager.users = lib.listToAttrs (map (username: {
      name = username;
      value = { imports = homeManagerModules.${username}; };
    }) config.users.list);
  };
}
