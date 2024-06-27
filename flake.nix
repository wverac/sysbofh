{
  description = "sysBOFH NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
  in {
    overlays = import ./overlays {inherit inputs;};
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
      # Work laptop - ThinkPad X1 Yoga Gen 6
      work = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          inputs.sops-nix.nixosModules.sops
          ./hosts/work/configuration.nix
        ];
      };
      # Personal laptop - ThinkPad X1 Carbon 6th
      overcloud = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          inputs.sops-nix.nixosModules.sops
          ./hosts/overcloud/configuration.nix
        ];
      };
      # New personal laptop - System76 Lemur Pro
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
      "bofh@work" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/work/home.nix
        ];
      };
      "link@overcloud" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/overcloud/home.nix
        ];
      };
      "bofh@sysbofh" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
        modules = [
          ./hosts/sysbofh/home.nix
        ];
      };
    };
  };
}
