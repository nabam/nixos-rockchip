{ pkgs ? import <nixpkgs> {} }:

let
  buildImage = { kernel, uBoot }: (
    with (import (<nixpkgs/nixos/lib/eval-config.nix>) {
      modules = [
          ./modules/sd-card/sd-image-rockchip-installer.nix
          { rockchip.uBoot = uBoot; boot.kernelPackages = kernel; }
      ];
    }); {
      inherit (config.system.build) sdImage;
    }
  );
  uBoot  = pkgs.callPackage ./pkgs/uboot-rockchip.nix {};
  kernel = pkgs.callPackage ./pkgs/linux-rockchip.nix {};
in {
  Quartz64A      = ( buildImage { uBoot = uBoot.uBootQuartz64A;      kernel = kernel.linux_6_1_rockchip; } ).sdImage;
  Quartz64B      = ( buildImage { uBoot = uBoot.uBootQuartz64B;      kernel = kernel.linux_6_1_rockchip; } ).sdImage;
  SoQuartzModelA = ( buildImage { uBoot = uBoot.uBootSoQuartzModelA; kernel = kernel.linux_6_2_rockchip; } ).sdImage;
  SoQuartzCM4IO  = ( buildImage { uBoot = uBoot.uBootSoQuartzCM4IO;  kernel = kernel.linux_6_2_rockchip; } ).sdImage;
  SoQuartzBlade  = ( buildImage { uBoot = uBoot.uBootSoQuartzBlade;  kernel = kernel.linux_6_2_rockchip; } ).sdImage;

  Rock64      = ( buildImage { uBoot = pkgs.ubootRock64;      kernel = kernel.linux_6_1_rockchip; } ).sdImage;
  RockPro64   = ( buildImage { uBoot = pkgs.ubootRockPro64;   kernel = kernel.linux_6_1_rockchip; } ).sdImage;
  ROKPCRK3399 = ( buildImage { uBoot = pkgs.ubootROCPCRK3399; kernel = kernel.linux_6_1_rockchip; } ).sdImage;
  PinebookPro = ( buildImage { uBoot = pkgs.ubootPinebookPro; kernel = kernel.linux_6_1_rockchip; } ).sdImage;
}
