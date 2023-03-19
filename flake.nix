{
  description = "Build NixOS images for rockchip based single computer boards";

  inputs = {
    nixpkgsStable.url   = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url           = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    let
      pkgs = import inputs.nixpkgsStable {
        system = "aarch64-linux";
        config = {
          allowUnfree = true;
        };
      };

      pkgsUnstable = import inputs.nixpkgsUnstable {
        system = "aarch64-linux";
        config = {
          allowUnfree = true;
        };
      };

      uBoot  = pkgs.callPackage ./pkgs/uboot-rockchip.nix {};
      kernel = pkgs.callPackage ./pkgs/linux-rockchip.nix { pkgs = pkgsUnstable; };

      boards = {
        "Quartz64A"      = { uBoot = uBoot.uBootQuartz64A;      kernel = kernel.linux_6_1_rockchip; };
        "Quartz64B"      = { uBoot = uBoot.uBootQuartz64B;      kernel = kernel.linux_6_1_rockchip; };
        "SoQuartzModelA" = { uBoot = uBoot.uBootSoQuartzModelA; kernel = kernel.linux_6_2_rockchip; };
        "SoQuartzCM4"    = { uBoot = uBoot.uBootSoQuartzCM4IO;  kernel = kernel.linux_6_2_rockchip; };
        "SoQuartzBlade"  = { uBoot = uBoot.uBootSoQuartzBlade;  kernel = kernel.linux_6_2_rockchip; };

        "Rock64"       = { uBoot = pkgs.ubootRock64;      kernel = kernel.linux_6_1_rockchip; };
        "RockPro64"    = { uBoot = pkgs.ubootRockPro64;   kernel = kernel.linux_6_1_rockchip; };
        "RockPCRK3399" = { uBoot = pkgs.ubootROCPCRK3399; kernel = kernel.linux_6_1_rockchip; };
        "PinebookPro"  = { uBoot = pkgs.ubootPinebookPro; kernel = kernel.linux_6_1_rockchip; };
      };

      osConfigs = builtins.mapAttrs
        (name: value: inputs.nixpkgsStable.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            self.nixosModules.sdImageRockchipInstaller
            { rockchip.uBoot = value.uBoot; boot.kernelPackages = value.kernel; }
            { nixpkgs.overlays = [ (final: super: { zfs = super.zfs.overrideAttrs (_: { meta.platforms = [ ]; }); }) ]; } # ZFS is broken on linux 6.2 from unstable
          ];
          specialArgs = {
            inherit inputs;
          };
        }) boards;

      images = builtins.mapAttrs
        (name: value: value.config.system.build.sdImage) osConfigs;
    in
    {
      nixosModules = {
        sdImageRockchipInstaller = import ./modules/sd-card/sd-image-rockchip-installer.nix;
        sdImageRockchip = import ./modules/sd-card/sd-image-rockchip.nix;
        dtOverlayQuartz64ASATA = import ./modules/dt-overlay/quartz64a-sata.nix;
      };
    } // inputs.utils.lib.eachDefaultSystem
      (system:
        {
          packages.image = images;
        }
      );
}
