{ lib, ... }:

{
  options.users.list = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "A list of all user accounts to be created on this system.
      This list is automatically merged from all modules that define it.";
  };
}