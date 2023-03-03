{
  description = "Build NixOS images for rockchip based single computer boards";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    let
      pkgs = import inputs.nixpkgs {
        system = "aarch64-linux";
        config = { allowUnfree = true; };
      };

      uBoot  = pkgs.callPackage ./pkgs/uboot-rockchip.nix {};
      kernel = pkgs.callPackage ./pkgs/linux-rockchip.nix {};

      boards = {
        "Quartz64A" = { uBoot = uBoot.uBootQuartz64A; kernel = kernel.linux_6_1_rockchip; };
        "Quartz64B" = { uBoot = uBoot.uBootQuartz64B; kernel = kernel.linux_6_1_rockchip; };
        "SoQuartz" =  { uBoot = uBoot.uBootSoQuartz;  kernel = kernel.linux_6_1_rockchip; };
      };

      osConfigs = builtins.mapAttrs
        (name: value: inputs.nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            self.nixosModules.sd-image-rockchip-installer
            { rockchip.uBoot = value.uBoot; boot.kernelPackages = value.kernel; }
          ];
          specialArgs = {
            inherit inputs;
          };
        }) boards;

      images = builtins.mapAttrs
        (name: value: value.config.system.build.sdImage) osConfigs;
    in
    {
      inherit kernel uBoot;

      nixosModules = {
        sd-image-rockchip-installer = import ./modules/sd-card/sd-image-rockchip-installer.nix;
        sd-image-rockchip = import ./modules/sd-card/sd-image-rockchip.nix;
      };
    } // inputs.utils.lib.eachDefaultSystem
      (system:
        {
          packages.image = images;
        }
      );
}
