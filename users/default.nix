{ lib, config, inputs, ... }:

{
  options.users.list = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "A list of all user accounts to be created on this system.";
  };

  config = lib.mkMerge [
    {
      users.users = lib.listToAttrs (map (username: {
        name = username;
        value = import ./${username}/user.nix;
      }) config.users.list);
    }

    {
      home-manager.users = lib.listToAttrs (map (username: {
        name = username;
        value = {
          imports = [
            inputs.stylix.homeModules.stylix
            # Update the path for home.nix as well
            ./${username}/home.nix
          ];
        };
      }) config.users.list);
    }
  ];
}
