{
  description = "sysBOFH NixOS configuration";

  inputs = {
    darwin.url = "github:lnl7/nix-darwin/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "github:Mic92/sops-nix";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    claude-code.url = "github:sadjow/claude-code-nix";
    codex-cli-nix.url = "github:sadjow/codex-cli-nix";
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
    # Package overlays
    overlays = {
      hydra = import ./overlays/hydra.nix;
      marktext = import ./overlays/marktext.nix;
      #nomachine = import ./overlays/nomachine.nix; # nixpkgs ships 10.2.3
      sops-go-builder = import ./overlays/sops-go-builder.nix;
      #picosvg = import ./overlays/picosvg.nix;
    };
    hydraJobs = import ./hydra.nix {inherit inputs outputs;};

    nixosConfigurations = {
      # Beelink S12 Pro Mini PC
      nixlab = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          {nixpkgs.overlays = [self.overlays.sops-go-builder];}
          inputs.sops-nix.nixosModules.sops
          ./hosts/nixlab/configuration.nix
        ];
      };
      # System76 Lemur Pro
      sysops = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          {nixpkgs.overlays = [self.overlays.sops-go-builder];}
          inputs.sops-nix.nixosModules.sops
          ./hosts/sysops/configuration.nix
        ];
      };
      # ASUS ProArt P14 (NVIDIA N1X, aarch64)
      hydra = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          {nixpkgs.overlays = [self.overlays.sops-go-builder];}
          inputs.sops-nix.nixosModules.sops
          ./hosts/hydra/configuration.nix
        ];
      };
    };
    homeConfigurations = {
      "tank@nixlab" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs;
          hostname = "nixlab";
        };
        modules = [
          ./hosts/nixlab/home.nix
        ];
      };
      "dozer@sysops" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {
          inherit inputs outputs;
          hostname = "sysops";
        };
        modules = [
          ./hosts/sysops/home.nix
        ];
      };
      "bofh@hydra" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        extraSpecialArgs = {
          inherit inputs outputs;
          hostname = "hydra";
        };
        modules = [
          ./hosts/hydra/home.nix
        ];
      };
      "wvera@m4nix" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          overlays = [self.overlays.sops-go-builder];
        };
        extraSpecialArgs = {
          inherit inputs outputs;
          hostname = "m4nix";
        };
        modules = [
          inputs.sops-nix.homeManagerModules.sops
          ./hosts/m4nix/home.nix
        ];
      };
    };
  };
}
