{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    inputs.nixvim.packages.${pkgs.system}.default
  ];

  programs.bash.shellAliases = {
    vim = "nvim";
  };

  environment.shellAliases = {
    vim = "nvim";
  };
}
