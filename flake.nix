{
  description = "Build NixOS images for rockchip based single computer boards";

  inputs = {
    nixpkgs-22-11.url    = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url            = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs:
    let
      pkgs = import inputs.nixpkgs-22-11 {
        system = "aarch64-linux";
        config = { allowUnfree = true; };
      };

      pkgs-unstable = import inputs.nixpkgs-unstable {
        config.allowBroken = true; # ZFS is broken on linux 6.2 from unstable
        system = "aarch64-linux";
        config = { allowUnfree = true; };
      };

      uBoot  = pkgs.callPackage ./pkgs/uboot-rockchip.nix {};
      kernel = pkgs.callPackage ./pkgs/linux-rockchip.nix { pkgs = pkgs-unstable; };

      boards = {
        "Quartz64A"     = { uBoot = uBoot.uBootQuartz64A; kernel = kernel.linux_6_1_rockchip; fdt = "rockchip/rk3566-quartz64-a.dtb"; };
        "Quartz64B"     = { uBoot = uBoot.uBootQuartz64B; kernel = kernel.linux_6_1_rockchip; fdt = "rockchip/rk3566-quartz64-n.dtb"; };
        "SoQuartzA"     = { uBoot = uBoot.uBootSoQuartz;  kernel = kernel.linux_6_2_rockchip; fdt = "rockchip/rk3566-soquartz-model-a.dtb";  };
        "SoQuartzCM4"   = { uBoot = uBoot.uBootSoQuartz;  kernel = kernel.linux_6_2_rockchip; fdt = "rockchip/rk3566-soquartz-cm4.dtb";  };
        "SoQuartzBlade" = { uBoot = uBoot.uBootSoQuartz;  kernel = kernel.linux_6_2_rockchip; fdt = "rockchip/rk3566-soquartz-blade.dtb";  };
      };

      osConfigs = builtins.mapAttrs
        (name: value: inputs.nixpkgs-22-11.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            self.nixosModules.sd-image-rockchip-installer
            { rockchip.uBoot = value.uBoot; boot.kernelPackages = value.kernel; hardware.deviceTree.name = value.fdt; }
          ];
          specialArgs = {
            inherit inputs;
          };
        }) boards;

      images = builtins.mapAttrs
        (name: value: value.config.system.build.sdImage) osConfigs;
    in
    {
      inherit kernel uBoot;

      nixosModules = {
        sd-image-rockchip-installer = import ./modules/sd-card/sd-image-rockchip-installer.nix;
        sd-image-rockchip = import ./modules/sd-card/sd-image-rockchip.nix;
      };
    } // inputs.utils.lib.eachDefaultSystem
      (system:
        {
          packages.image = images;
        }
      );
}
