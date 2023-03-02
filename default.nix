{ pkgs ? import <nixpkgs> {} }:

let
  quartz64a = with (import (<nixpkgs/nixos/lib/eval-config.nix>) {
    modules = [
        ./modules/sd-card/sd-image-rk3566-installer.nix
        {
          rk3566.uBoot = (pkgs.callPackage ./pkgs/uboot-rk3566.nix {}).uBootQuartz64A;
        }
    ];
  }); {
    inherit (config.system.build) sdImage;
  }.sdImage;

  quartz64b = with (import (<nixpkgs/nixos/lib/eval-config.nix>) {
    modules = [
        ./modules/sd-card/sd-image-rk3566-installer.nix
        {
          rk3566.uBoot = (pkgs.callPackage ./pkgs/uboot-rk3566.nix {}).uBootQuartz64B;
        }
    ];
  }); {
    inherit (config.system.build) sdImage;
  }.sdImage;

  soquartz = with (import (<nixpkgs/nixos/lib/eval-config.nix>) {
    modules = [
        ./modules/sd-card/sd-image-rk3566-installer.nix
        {
          rk3566.uBoot = (pkgs.callPackage ./pkgs/uboot-rk3566.nix {}).uBootSoQuartz;
        }
    ];
  }); {
    inherit (config.system.build) sdImage;
  }.sdImage;
in {
  inherit quartz64a quartz64b soquartz;
}
