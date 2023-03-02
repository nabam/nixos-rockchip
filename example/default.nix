{ pkgs ? import <nixpkgs> {} }:

with (import (<nixpkgs/nixos/lib/eval-config.nix>) {
  modules = [ 
      <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
      ../modules/sd-card/sd-image-rk3566.nix
      ./config.nix
  ];
});

{
  inherit (config.system.build) sdImage;
}
