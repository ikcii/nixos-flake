{ lib, ... }: {
  options.users.common = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "List of usernames to be created on ALL hosts.";
  };
}
