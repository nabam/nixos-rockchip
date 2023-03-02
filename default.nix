{ pkgs ? import <nixpkgs> {} }:

with (import (<nixpkgs/nixos/lib/eval-config.nix>) {
  modules = [ 
      ./modules/sd-card/sd-image-rk3566-installer.nix
  ];
});

{
  inherit (config.system.build) sdImage;
}
