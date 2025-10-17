{ lib, ... }: {
  options.users.hostSpecific = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "List of usernames to be created ONLY on this specific host.";
  };
}
