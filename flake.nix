{
  description = "Build NixOS images for rockchip based computers";

  inputs = {
    nixpkgsStable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgsUnstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    let
      # Use cross-compilation for uBoot and Kernel.
      pkgs = system:
        import inputs.nixpkgsStable {
          inherit system;
          crossSystem.system = "aarch64-linux";
          config.allowUnfree = true; # for arm-trusted-firmware
        };

      pkgsUnstable = system:
        import inputs.nixpkgsUnstable {
          inherit system;
          crossSystem.system = "aarch64-linux";
          config.allowUnfree = true; # for arm-trusted-firmware
        };

      uBoot = system:
        (pkgsUnstable system).callPackage ./pkgs/uboot-rockchip.nix { };
      kernel = system:
        (pkgsUnstable system).callPackage ./pkgs/linux-rockchip.nix { };
      bes2600Firmware = system:
        (pkgsUnstable system).callPackage ./pkgs/bes2600-firmware.nix { };
      armbian-firmware = system:
        (pkgsUnstable system).callPackage ./pkgs/armbian-firmware.nix { };
      brcm43752pcieFirmware = system: (armbian-firmware system).brcm-43752-pcie;

      # ZFS is broken on kernel from unstable.
      noZFS = {
        nixpkgs.overlays = [
          (final: super: {
            zfs = super.zfs.overrideAttrs (_: { meta.platforms = [ ]; });
          })
        ];
      };

      bes2600 = system: {
        nixpkgs.config.allowUnfree = true;
        hardware.firmware = [ (bes2600Firmware system) ];
      };

      brcm43752 = system: {
        nixpkgs.config.allowUnfree = true;
        hardware.firmware = [ (brcm43752pcieFirmware system) ];
      };

      boards = system: {
        "Quartz64A" = {
          uBoot = (uBoot system).uBootQuartz64A;
          kernel = (kernel system).linux_6_6_rockchip;
          extraModules = [ self.nixosModules.dtOverlayPCIeFix ];
        };
        "Quartz64B" = {
          uBoot = (uBoot system).uBootQuartz64B;
          kernel = (kernel system).linux_6_6_rockchip;
          extraModules = [ self.nixosModules.dtOverlayPCIeFix ];
        };
        "SoQuartzModelA" = {
          uBoot = (uBoot system).uBootSoQuartzModelA;
          kernel = (kernel system).linux_6_6_rockchip;
          extraModules = [ ];
        };
        "SoQuartzCM4" = {
          uBoot = (uBoot system).uBootSoQuartzCM4IO;
          kernel = (kernel system).linux_6_6_rockchip;
          extraModules = [ ];
        };
        "SoQuartzBlade" = {
          uBoot = (uBoot system).uBootSoQuartzBlade;
          kernel = (kernel system).linux_6_6_rockchip;
          extraModules = [ ];
        };
        "PineTab2" = {
          uBoot = (uBoot system).uBootPineTab2;
          kernel = (kernel system).linux_6_15_pinetab;
          extraModules = [ (bes2600 system) noZFS ];
        };
        "Rock64" = {
          uBoot = (uBoot system).uBootRock64;
          kernel = (kernel system).linux_6_6_rockchip;
          extraModules = [ ];
        };
        "RockPro64" = {
          uBoot = (uBoot system).uBootRockPro64;
          kernel = (kernel system).linux_6_6_rockchip;
          extraModules = [ ];
        };
        "ROCPCRK3399" = {
          uBoot = (uBoot system).uBootROCPCRK3399;
          kernel = (kernel system).linux_6_6_rockchip;
          extraModules = [ ];
        };
        "PinebookPro" = {
          uBoot = (uBoot system).uBootPinebookPro;
          kernel = (kernel system).linux_6_6_rockchip;
          extraModules = [ ];
        };
        "OrangePiCM4" = {
          uBoot = (uBoot system).uBootOrangePiCM4;
          kernel = (kernel system).linux_6_6_rockchip;
          extraModules = [ ];
        };
        "OrangePi5B" = {
          uBoot = (uBoot system).uBootOrangePi5B;
          kernel = (kernel system).linux_6_13_orangepi5b;
          extraModules =
            [ (brcm43752 system) noZFS self.nixosModules.dtOrangePi5B ];
        };
        "RadxaCM3IO" = {
          uBoot = (uBoot system).uBootRadxaCM3IO;
          kernel = (kernel system).linux_6_12_rockchip;
          extraModules = [ noZFS ];
        };
        "RadxaRock4" = {
          uBoot = (uBoot system).uBootRadxaRock4;
          kernel = (kernel system).linux_6_12_rockchip;
          extraModules = [ noZFS ];
        };
        "RadxaRock4SE" = {
          uBoot = (uBoot system).uBootRadxaRock4SE;
          kernel = (kernel system).linux_6_12_rockchip;
          extraModules = [ noZFS ];
        };
      };

      osConfigs = system:
        builtins.mapAttrs (name: value:
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
            ] ++ value.extraModules;
          }) (boards system);

      images = system:
        builtins.mapAttrs (name: value: value.config.system.build.sdImage)
        (osConfigs system);
    in {
      nixosModules = {
        inherit noZFS;
        sdImageRockchipInstaller =
          import ./modules/sd-card/sd-image-rockchip-installer.nix;
        sdImageRockchip = import ./modules/sd-card/sd-image-rockchip.nix;
        dtOverlayQuartz64ASATA = import ./modules/dt-overlay/quartz64a-sata.nix;
        dtOverlayPCIeFix = import ./modules/dt-overlay/pcie-fix.nix;
        dtOrangePi5B = import ./modules/dt-overlay/rk3588s-orangepi5b.nix;
      };
    } // inputs.utils.lib.eachDefaultSystem (system: {
      legacyPackages = {
        kernel_linux_6_6_rockchip = (kernel system).linux_6_6_rockchip;
        kernel_linux_6_12_rockchip = (kernel system).linux_6_12_rockchip;
        kernel_linux_6_16_rockchip = (kernel system).linux_6_16_rockchip;
        kernel_linux_6_15_pinetab = (kernel system).linux_6_15_pinetab;
        kernel_linux_6_13_orangepi5b = (kernel system).linux_6_13_orangepi5b;
      };
      packages = (images system) // {
        uBootQuartz64A = (uBoot system).uBootQuartz64A;
        uBootQuartz64B = (uBoot system).uBootQuartz64B;
        uBootPineTab2 = (uBoot system).uBootPineTab2;
        uBootPinebookPro = (uBoot system).uBootPinebookPro;
        uBootRockPro64 = (uBoot system).uBootRockPro64;
        uBootROCPCRK3399 = (uBoot system).uBootROCPCRK3399;
        uBootRock64 = (uBoot system).uBootRock64;

        uBootSoQuartzModelA = (uBoot system).uBootSoQuartzModelA;
        uBootSoQuartzCM4IO = (uBoot system).uBootSoQuartzCM4IO;
        uBootSoQuartzBlade = (uBoot system).uBootSoQuartzBlade;

        uBootOrangePiCM4 = (uBoot system).uBootOrangePiCM4;

        uBootRadxaCM3IO = (uBoot system).uBootRadxaCM3IO;
        uBootRadxaRock4 = (uBoot system).uBootRadxaRock4;
        uBootRadxaRock4SE = (uBoot system).uBootRadxaRock4SE;

        bes2600 = (bes2600Firmware system);
      };
      formatter = (import inputs.nixpkgsStable { inherit system; }).nixfmt;
    });
}
