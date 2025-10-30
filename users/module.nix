{ lib, config, inputs, ... }:

{
  config = lib.mkMerge [
    # Generate the top-level system user accounts from the final list
    {
      users.users = lib.listToAttrs (map (username: {
        name = username;
        value = import ./accounts/${username}/user.nix;
      }) config.users.list);
    }

    # Generate the Home Manager configurations from the final list
    {
      home-manager.users = lib.listToAttrs (map (username: {
        name = username;
        value = {
          imports = [
            inputs.stylix.homeModules.stylix
            ./accounts/${username}/home.nix
          ];
        };
      }) config.users.list);
    }
  ];
}