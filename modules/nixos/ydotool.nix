{
  config,
  lib,
  ...
}: let
  normalUsers = lib.attrNames (lib.filterAttrs (_: user: user.isNormalUser) config.users.users);
in {
  programs.ydotool.enable = true;
  users.groups.${config.programs.ydotool.group}.members = normalUsers;
}
