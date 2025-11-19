{
  description = "Build example NixOS image for Quartz64A";

  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    rockchip = {
      url = "github:nabam/nixos-rockchip";
    };
  };

  # Use cache with packages from nabam/nixos-rockchip CI.
  nixConfig = {
    extra-substituters = [ "https://nabam-nixos-rockchip.cachix.org" ];
    extra-trusted-public-keys = [
      "nabam-nixos-rockchip.cachix.org-1:BQDltcnV8GS/G86tdvjLwLFz1WeFqSk7O9yl+DR0AVM"
    ];
  };

  outputs =
    { self, ... }@inputs:
    let
      osConfig =
        buildPlatform:
        inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            inputs.rockchip.nixosModules.sdImageRockchip
            inputs.rockchip.nixosModules.dtOverlayQuartz64ASATA
            inputs.rockchip.nixosModules.dtOverlayPCIeFix
            inputs.rockchip.nixosModules.noZFS
            ./config.nix
            {
              # Use cross-compilation for uBoot and Kernel.
              rockchip.uBoot = inputs.rockchip.packages.${buildPlatform}.uBootQuartz64A;
              boot.kernelPackages = inputs.rockchip.legacyPackages.${buildPlatform}.kernel_linux_6_12_rockchip;
            }
          ];
        };
    in
    {
      nixosConfigurations.quartz64 = osConfig "aarch64-linux";
    }
    // inputs.utils.lib.eachDefaultSystem (system: {
      packages.image = (osConfig system).config.system.build.sdImage;
      packages.default = self.packages.${system}.image;
    });
}
