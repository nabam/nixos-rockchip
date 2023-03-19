{
  description = "Build NixOS images for rockchip based single computer boards";

  inputs = {
    utils.url    = "github:numtide/flake-utils";
    nixpkgs.url  = "github:NixOS/nixpkgs/nixos-22.11";

    rockchip = {
      url = "github:nabam/nixos-rockchip";
      # url = "path:..";

      inputs.utils.follows         = "utils";
      inputs.nixpkgsStable.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
    let
      pkgs = import inputs.nixpkgs {
        system = "aarch64-linux";
        config = { allowUnfree = true; };
      };
      osConfig = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          inputs.rockchip.nixosModules.sdImageRockchip
          inputs.rockchip.nixosModules.dtOverlayQuartz64ASATA
          ./config.nix
          { 
            rockchip.uBoot = inputs.rockchip.uBoot.uBootQuartz64A; 
            # boot.kernelPackages = inputs.rockchip.kernel.linux_6_1;
            boot.kernelPackages = inputs.rockchip.kernel.linux_6_1_rockchip;
          }
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    in {
      nixosConfigurations.quartz64 = osConfig;
    } // inputs.utils.lib.eachDefaultSystem ( system: {
      packages.image = osConfig.config.system.build.sdImage;
      defaultPackage = self.packages."${system}".image;
    });
}
