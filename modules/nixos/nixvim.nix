{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
  # Declared in nixvim options
  programs.bash.shellAliases = {
    vim = "nvim";
  };
  environment.shellAliases = {
    vim = "nvim";
  };
}
