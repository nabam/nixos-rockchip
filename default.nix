{ pkgs ? import <nixpkgs> {} }:

let
  buildImage = uBootPkg: (
    with (import (<nixpkgs/nixos/lib/eval-config.nix>) {
      modules = [
          ./modules/sd-card/sd-image-rockchip-installer.nix
          { rockchip.uBoot = uBootPkg;  }
      ];
    }); {
      inherit (config.system.build) sdImage;
    }
  );
  uBoot = pkgs.callPackage ./pkgs/uboot-rockchip.nix {};
in {
  quartz64a = ( buildImage uBoot.uBootQuartz64A ).sdImage;
  quartz64b = ( buildImage uBoot.uBootQuartz64B ).sdImage;
  soQuartz  = ( buildImage uBoot.uBootSoQuartz  ).sdImage;
}
