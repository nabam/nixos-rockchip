{ pkgs ? import <nixpkgs> {} }:

let
  quartz64a = with (import (<nixpkgs/nixos/lib/eval-config.nix>) {
    modules = [
        ./modules/sd-card/sd-image-rk3566-installer.nix
        ./modules/sd-card/sd-image-quartz64a.nix
    ];
  }); {
    inherit (config.system.build) sdImage;
  }.sdImage;

  quartz64b = with (import (<nixpkgs/nixos/lib/eval-config.nix>) {
    modules = [
        ./modules/sd-card/sd-image-rk3566-installer.nix
        ./modules/sd-card/sd-image-quartz64b.nix
    ];
  }); {
    inherit (config.system.build) sdImage;
  }.sdImage;

  soquartz = with (import (<nixpkgs/nixos/lib/eval-config.nix>) {
    modules = [
        ./modules/sd-card/sd-image-rk3566-installer.nix
        ./modules/sd-card/sd-image-soquartz.nix
    ];
  }); {
    inherit (config.system.build) sdImage;
  }.sdImage;
in {
  inherit quartz64a quartz64b soquartz;
}
