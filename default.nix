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
  quartz64a      = ( buildImage { uBoot = uBoot.uBootQuartz64A;      kernel = kernel.linux_6_1_rockchip; } ).sdImage;
  quartz64b      = ( buildImage { uBoot = uBoot.uBootQuartz64B;      kernel = kernel.linux_6_1_rockchip; } ).sdImage;
  soQuartzModelA = ( buildImage { uBoot = uBoot.uBootSoQuartzModelA; kernel = kernel.linux_6_2_rockchip; } ).sdImage;
  soQuartzCM4IO  = ( buildImage { uBoot = uBoot.uBootSoQuartzCM4IO;  kernel = kernel.linux_6_2_rockchip; } ).sdImage;
  soQuartzBlade  = ( buildImage { uBoot = uBoot.uBootSoQuartzBlade;  kernel = kernel.linux_6_2_rockchip; } ).sdImage;
}
