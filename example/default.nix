{ pkgs ? import <nixpkgs> {} }:

with (import (<nixpkgs/nixos/lib/eval-config.nix>) {
  modules = [ 
      <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
      ../modules/sd-card/sd-image-rockchip.nix
      ./config.nix
      { 
        rockchip.uBoot = (pkgs.callPackage ../pkgs/uboot-rockchip.nix {}).uBootQuartz64A; 
        boot.kernelPackages = pkgs.linuxPackages_6_1;
      }
  ];
});
{
  inherit (config.system.build) sdImage;
}
