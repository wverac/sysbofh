{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    inputs.nixvim.packages.${pkgs.system}.default
  ];
  # Declared in nixvim options
  programs.bash.shellAliases = {
    vim = "nvim";
  };
  environment.shellAliases = {
    vim = "nvim";
  };
}
