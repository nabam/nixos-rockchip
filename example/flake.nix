{
  description = "Build NixOS images for rockchip based single computer boards";

  inputs = {
    utils.url    = "github:numtide/flake-utils";
    nixpkgs.url  = "github:NixOS/nixpkgs/nixos-23.05";

    rockchip = {
      url = "github:nabam/nixos-rockchip";
      # url = "path:..";

      inputs.utils.follows         = "utils";
      inputs.nixpkgsStable.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:
    let
      osConfig = system: inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          inputs.rockchip.nixosModules.sdImageRockchip
          inputs.rockchip.nixosModules.dtOverlayQuartz64ASATA
          inputs.rockchip.nixosModules.dtOverlayPCIeFix
          ./config.nix
          {
            # Use cross-compilation for uBoot and Kernel
            rockchip.uBoot = (inputs.rockchip.uBoot system).uBootQuartz64A;
            # boot.kernelPackages = (inputs.rockchip.kernel system).linux_6_1;
            boot.kernelPackages = (inputs.rockchip.kernel system).linux_6_1_rockchip;
          }
          # Cross-compiling the whole system is hard, install from caches or compile with emulation instead
          # { nixpkgs.crossSystem.system = "aarch64-linux"; nixpkgs.system = system;}
        ];
      };
    in {
      nixosConfigurations.quartz64 = osConfig "aarch64-linux";
    } // inputs.utils.lib.eachDefaultSystem ( system: {
      packages.image = (osConfig system).config.system.build.sdImage;
      defaultPackage = self.packages."${system}".image;
    });
}
