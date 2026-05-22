{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
let
  bes2600Firmware = pkgs.callPackage ../pkgs/bes2600-firmware.nix { };
in
{
  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage ../pkgs/bes2600-kernel-module.nix { })
  ];
  boot.kernelModules = [ "bes2600" ];
  hardware.firmware = [ bes2600Firmware ];
}
