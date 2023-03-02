{ pkgs, ... }:
{
  imports = [
    ./sd-image-rk3566.nix
  ];

  rk3566.uBoot = (pkgs.callPackage ../../pkgs/uboot-rk3566.nix {}).uBootQuartz64B;
}
