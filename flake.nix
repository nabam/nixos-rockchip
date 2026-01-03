{
  description = "Build NixOS images for rockchip based computers";

  inputs = {
    nixpkgsStable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, ... }@inputs:
    let
      # Use cross-compilation for uBoot and Kernel.
      pkgs =
        system:
        import inputs.nixpkgsStable {
          inherit system;
          crossSystem.system = "aarch64-linux";
          config.allowUnfree = true; # for arm-trusted-firmware
        };

      pkgsUnstable =
        system:
        import inputs.nixpkgsUnstable {
          inherit system;
          crossSystem.system = "aarch64-linux";
          config.allowUnfree = true; # for arm-trusted-firmware
        };

      scope =
        system:
        with (pkgsUnstable system);
        lib.makeScope newScope (self-scope: {
          pkgs-stable = pkgs system;
          uBoot = self-scope.callPackage ./pkgs/uboot-rockchip.nix { };
          kernel = self-scope.callPackage ./pkgs/linux-rockchip.nix { };
          bes2600Firmware = self-scope.callPackage ./pkgs/bes2600-firmware.nix { };
          armbian-firmware = self-scope.callPackage ./pkgs/armbian-firmware.nix { };
          brcm43752pcieFirmware = self-scope.armbian-firmware.brcm-43752-pcie;
        });

      # ZFS is broken on kernel from unstable.
      noZFS = {
        nixpkgs.overlays = [
          (final: super: {
            zfs = super.zfs.overrideAttrs (_: {
              meta.platforms = [ ];
            });
          })
        ];
      };

      bes2600 =
        system: with (scope system); {
          nixpkgs.config.allowUnfree = true;
          hardware.firmware = [ bes2600Firmware ];
        };

      brcm43752 =
        system: with (scope system); {
          nixpkgs.config.allowUnfree = true;
          hardware.firmware = [ brcm43752pcieFirmware ];
        };

      boards =
        system: with (scope system); {
          "Quartz64A" = {
            uBoot = uBoot.uBootQuartz64A;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [
              self.nixosModules.dtOverlayPCIeFix
              noZFS
            ];
          };
          "Quartz64B" = {
            uBoot = uBoot.uBootQuartz64B;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [
              self.nixosModules.dtOverlayPCIeFix
              noZFS
            ];
          };
          "SoQuartzModelA" = {
            uBoot = uBoot.uBootSoQuartzModelA;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [ noZFS ];
          };
          "SoQuartzCM4" = {
            uBoot = uBoot.uBootSoQuartzCM4IO;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [ noZFS ];
          };
          "SoQuartzBlade" = {
            uBoot = uBoot.uBootSoQuartzBlade;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [ noZFS ];
          };
          "PineTab2" = {
            uBoot = uBoot.uBootPineTab2;
            kernel = kernel.linux_6_18_pinetab_stable;
            extraModules = [
              (bes2600 system)
              noZFS
            ];
          };
          "Rock64" = {
            uBoot = uBoot.uBootRock64;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [ noZFS ];
          };
          "RockPro64" = {
            uBoot = uBoot.uBootRockPro64;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [ noZFS ];
          };
          "ROCPCRK3399" = {
            uBoot = uBoot.uBootROCPCRK3399;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [ noZFS ];
          };
          "PinebookPro" = {
            uBoot = uBoot.uBootPinebookPro;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [ noZFS ];
          };
          "OrangePiCM4" = {
            uBoot = uBoot.uBootOrangePiCM4;
            kernel = kernel.linux_6_17_rockchip_stable;
            extraModules = [ noZFS ];
          };
          "OrangePi5B" = {
            uBoot = uBoot.uBootOrangePi5B;
            kernel = kernel.linux_6_17_orangepi5b_stable;
            extraModules = [
              (brcm43752 system)
              noZFS
              self.nixosModules.dtOrangePi5B
            ];
          };
          "RadxaCM3IO" = {
            uBoot = uBoot.uBootRadxaCM3IO;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [ noZFS ];
          };
          "RadxaRock4" = {
            uBoot = uBoot.uBootRadxaRock4;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [ noZFS ];
          };
          "RadxaRock4SE" = {
            uBoot = uBoot.uBootRadxaRock4SE;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [ noZFS ];
          };
          "RadxaRock4CPlus" = {
            uBoot = uBoot.uBootRadxaRock4CPlus;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [ noZFS ];
          };
          "NanoPC-T6" = {
            uBoot = uBoot.uBootNanoPCT6;
            kernel = kernel.linux_latest_rockchip_stable;
            extraModules = [ noZFS ];
          };
        };

      osConfigs =
        system:
        builtins.mapAttrs (
          name: value:
          inputs.nixpkgsStable.lib.nixosSystem {
            system = "aarch64-linux";

            modules = [
              self.nixosModules.sdImageRockchipInstaller
              {
                system.stateVersion = "24.05";

                rockchip.uBoot = value.uBoot;
                boot.kernelPackages = value.kernel;
              }
              # Cross-compiling the whole system is hard, install from caches or compile with emulation instead.
              # { nixpkgs.crossSystem.system = "aarch64-linux"; nixpkgs.system = system;}
            ]
            ++ value.extraModules;
          }
        ) (boards system);

      images =
        system: builtins.mapAttrs (name: value: value.config.system.build.sdImage) (osConfigs system);
    in
    {
      nixosModules = {
        inherit noZFS;
        sdImageRockchipInstaller = import ./modules/sd-card/sd-image-rockchip-installer.nix;
        sdImageRockchip = import ./modules/sd-card/sd-image-rockchip.nix;
        dtOverlayQuartz64ASATA = import ./modules/dt-overlay/quartz64a-sata.nix;
        dtOverlayPCIeFix = import ./modules/dt-overlay/pcie-fix.nix;
        dtOrangePi5B = import ./modules/dt-overlay/rk3588s-orangepi5b.nix;
      };
    }
    // inputs.utils.lib.eachDefaultSystem (
      system: with (scope system); {
        legacyPackages = {
          kernel_linux_latest_rockchip_stable = kernel.linux_latest_rockchip_stable;
          kernel_linux_latest_rockchip_unstable = kernel.linux_latest_rockchip_unstable;

          kernel_linux_6_18_pinetab_stable = kernel.linux_6_18_pinetab_stable;
          kernel_linux_6_18_pinetab_unstable = kernel.linux_6_18_pinetab_unstable;

          kernel_linux_6_17_orangepi5b_stable = kernel.linux_6_17_orangepi5b_stable;
          kernel_linux_6_17_orangepi5b_unstable = kernel.linux_6_17_orangepi5b_unstable;
        };
        packages = (images system) // {
          uBootQuartz64A = uBoot.uBootQuartz64A;
          uBootQuartz64B = uBoot.uBootQuartz64B;
          uBootPineTab2 = uBoot.uBootPineTab2;
          uBootPinebookPro = uBoot.uBootPinebookPro;
          uBootRockPro64 = uBoot.uBootRockPro64;
          uBootROCPCRK3399 = uBoot.uBootROCPCRK3399;
          uBootRock64 = uBoot.uBootRock64;

          uBootSoQuartzModelA = uBoot.uBootSoQuartzModelA;
          uBootSoQuartzCM4IO = uBoot.uBootSoQuartzCM4IO;
          uBootSoQuartzBlade = uBoot.uBootSoQuartzBlade;

          uBootOrangePiCM4 = uBoot.uBootOrangePiCM4;
          uBootOrangePi5B = uBoot.uBootOrangePi5B;

          uBootRadxaCM3IO = uBoot.uBootRadxaCM3IO;
          uBootRadxaRock4 = uBoot.uBootRadxaRock4;
          uBootRadxaRock4SE = uBoot.uBootRadxaRock4SE;
          uBootRadxaRock4CPlus = uBoot.uBootRadxaRock4CPlus;

          uBootNanoPCT6 = uBoot.uBootNanoPCT6;

          bes2600 = bes2600Firmware;
          brcm43752 = brcm43752pcieFirmware;
        };
        formatter = (import inputs.nixpkgsStable { inherit system; }).nixfmt-tree;
      }
    );
}
