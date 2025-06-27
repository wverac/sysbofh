{
  description = "sysBOFH NixOS configuration";

  inputs = {
    darwin.url = "github:lnl7/nix-darwin/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    # My sysBOFH NeoVim configuration
    nixvim.url = "github:wverac/nixvim";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    darwin,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    hydraJobs = import ./hydra.nix {inherit inputs outputs;};

    nixosConfigurations = {
      # Home lab - Beelink S12 Pro Mini PC
      nixlab = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          inputs.sops-nix.nixosModules.sops
          ./hosts/nixlab/configuration.nix
        ];
      };
      # Personal laptop - System76 Lemur Pro
      sysbofh = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          inputs.sops-nix.nixosModules.sops
          ./hosts/sysbofh/configuration.nix
        ];
      };
    };
    homeConfigurations = {
      "tank@nixlab" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/nixlab/home.nix
        ];
      };
      "bofh@sysbofh" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/sysbofh/home.nix
        ];
      };
      "wvera@minix" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/minix/home.nix
        ];
      };
    };
  };
}
