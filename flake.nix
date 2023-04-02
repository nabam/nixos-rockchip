{
  description = "Build NixOS images for rockchip based single computer boards";

  inputs = {
    nixpkgsStable.url   = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url           = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    let
      # Use cross-compilation for uBoot and Kernel
      pkgs = system: import inputs.nixpkgsStable {
        inherit system;
        crossSystem.system = "aarch64-linux";
      };

      pkgsUnstable = system: import inputs.nixpkgsUnstable {
        inherit system;
        crossSystem.system = "aarch64-linux";
      };

      uBoot  = system: (pkgs system).callPackage ./pkgs/uboot-rockchip.nix {};
      kernel = system: (pkgsUnstable system).callPackage ./pkgs/linux-rockchip.nix {};

      boards = system: {
        "Quartz64A"      = { uBoot = (uBoot system).uBootQuartz64A;      kernel = (kernel system).linux_6_1_rockchip; };
        "Quartz64B"      = { uBoot = (uBoot system).uBootQuartz64B;      kernel = (kernel system).linux_6_1_rockchip; };
        "SoQuartzModelA" = { uBoot = (uBoot system).uBootSoQuartzModelA; kernel = (kernel system).linux_6_2_rockchip; };
        "SoQuartzCM4"    = { uBoot = (uBoot system).uBootSoQuartzCM4IO;  kernel = (kernel system).linux_6_2_rockchip; };
        "SoQuartzBlade"  = { uBoot = (uBoot system).uBootSoQuartzBlade;  kernel = (kernel system).linux_6_2_rockchip; };

        "Rock64"      = { uBoot = (pkgs system).ubootRock64;      kernel = (kernel system).linux_6_1_rockchip; };
        "RockPro64"   = { uBoot = (pkgs system).ubootRockPro64;   kernel = (kernel system).linux_6_1_rockchip; };
        "ROCPCRK3399" = { uBoot = (pkgs system).ubootROCPCRK3399; kernel = (kernel system).linux_6_1_rockchip; };
        "PinebookPro" = { uBoot = (pkgs system).ubootPinebookPro; kernel = (kernel system).linux_6_1_rockchip; };
      };

      osConfigs = system: builtins.mapAttrs
        (name: value: inputs.nixpkgsStable.lib.nixosSystem {
          system = "aarch64-linux";

          modules = [
            self.nixosModules.sdImageRockchipInstaller
            { rockchip.uBoot = value.uBoot; boot.kernelPackages = value.kernel; }
            { nixpkgs.overlays = [ (final: super: { zfs = super.zfs.overrideAttrs (_: { meta.platforms = [ ]; }); }) ]; } # ZFS is broken on linux 6.2 from unstable
            # Cross-compiling the whole system is hard, install from caches or compile with emulation instead
            # { nixpkgs.crossSystem.system = "aarch64-linux"; nixpkgs.system = system;}
          ];
        }) (boards system);

      images = system: builtins.mapAttrs
        (name: value: value.config.system.build.sdImage) (osConfigs system);
    in
    {
      inherit uBoot kernel;

      nixosModules = {
        sdImageRockchipInstaller = import ./modules/sd-card/sd-image-rockchip-installer.nix;
        sdImageRockchip = import ./modules/sd-card/sd-image-rockchip.nix;
        dtOverlayQuartz64ASATA = import ./modules/dt-overlay/quartz64a-sata.nix;
      };
    } // inputs.utils.lib.eachDefaultSystem
      (system:
        {
          packages = (images system) // {
            kernel_linux_6_1_rockchip = (kernel system).linux_6_1_rockchip.kernel;
            kernel_linux_6_2_rockchip = (kernel system).linux_6_2_rockchip.kernel;

            uBootQuartz64A = (uBoot system).uBootQuartz64A;
            uBootQuartz64B = (uBoot system).uBootQuartz64B;

            uBootSoQuartzModelA = (uBoot system).uBootSoQuartzModelA;
            uBootSoQuartzCM4IO  = (uBoot system).uBootSoQuartzCM4IO;
            uBootSoQuartzBlade  = (uBoot system).uBootSoQuartzBlade;
          };
        }
      );
}
