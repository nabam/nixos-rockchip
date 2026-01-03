{
  pkgs,
  pkgs-stable,
  stdenv,
  lib,
  fetchpatch,
  fetchFromGitHub,
  buildUBoot,
  buildPackages,
}:

let
  buildPatchedUBoot =
    {
      defconfig,
      BL31,
      ROCKCHIP_TPL ? "",
      extraPatches ? [ ],
    }:
    let
      inherit
        defconfig
        BL31
        ROCKCHIP_TPL
        extraPatches
        ;
    in
    buildUBoot {
      defconfig = defconfig;
      filesToInstall = [
        "u-boot-rockchip.bin"
        "u-boot-rockchip-spi.bin"
      ];

      extraPatches = [ ./ramdisk_addr_r.patch ] ++ extraPatches;
      extraConfiG = [
        "CONFIG_CMD_BOOTEFI=y"
        "CONFIG_EFILOADER=y"
        "CONFIG_BLK=y"
        "CONFIG_PARTITIONS=y"
        "CONFIG_BOOTM_EFI=y"
      ];

      BL31 = BL31;
      ROCKCHIP_TPL = ROCKCHIP_TPL;

      extraMeta = {
        platforms = [ "aarch64-linux" ];
        license = lib.licenses.unfreeRedistributableFirmware;
      };
    };
  buildRK3328UBoot =
    defconfig:
    buildPatchedUBoot {
      inherit defconfig;
      BL31 = "${pkgs.armTrustedFirmwareRK3328}/bl31.elf";
    };
  buildRK3399UBoot =
    defconfig:
    buildPatchedUBoot {
      inherit defconfig;
      BL31 = "${pkgs.armTrustedFirmwareRK3399}/bl31.elf";
    };
  buildRK3566UBoot =
    {
      defconfig,
      spi ? true,
    }:
    let
      version = "v2024.04-0-g25049ad5608";
      src = fetchFromGitHub {
        owner = "u-boot";
        repo = "u-boot";
        rev = "v2024.04";
        sha256 = "IlaDdjKq/Pq2orzcU959h93WXRZfvKBGDO/MFw9mZMg=";
      };
      rkbin = fetchFromGitHub {
        owner = "rockchip-linux";
        repo = "rkbin";
        rev = "b4558da0860ca48bf1a571dd33ccba580b9abe23";
        sha256 = "KUZQaQ+IZ0OynawlYGW99QGAOmOrGt2CZidI3NTxFw8=";
      };
    in
    buildUBoot {
      inherit defconfig src version;
      filesToInstall =
        if spi then
          [
            "u-boot-rockchip.bin"
            "u-boot-rockchip-spi.bin"
          ]
        else
          [ "u-boot-rockchip.bin" ];
      extraPatches = [
        (fetchpatch {
          name = "quartz64.patch";
          url = "https://github.com/Kwiboo/u-boot-rockchip/compare/25049ad560826f7dc1c4740883b0016014a59789...830cfcfdf54a1f08a3ca7fc17e69b4bc18cece50.diff";
          sha256 = "5mLjKiRpfnLCNVnyNuxBcDmmXg8xwcki3mmLisS4YbU=";
        })
      ];
      BL31 = (rkbin + "/bin/rk35/rk3568_bl31_v1.43.elf");
      ROCKCHIP_TPL = (rkbin + "/bin/rk35/rk3566_ddr_1056MHz_v1.18.bin");
    };
  buildRK3588UBoot =
    defconfig:
    let
      src = pkgs-stable.fetchFromGitHub {
        owner = "u-boot";
        repo = "u-boot";
        rev = "v2025.01";
        sha256 = "n63E3AHzbkn/SAfq+DHYDsBMY8qob+cbcoKgPKgE4ps=";
      };
    in
    pkgs-stable.buildUBoot {
      inherit defconfig src;
      version = "v2025.01-1-ga79ebd4e16";
      BL31 = "${pkgs-stable.armTrustedFirmwareRK3588}/bl31.elf";
      ROCKCHIP_TPL = pkgs-stable.rkbin.TPL_RK3588;
      filesToInstall = [ "u-boot-rockchip.bin" ];
      extraPatches = [
        ./patches/u-boot/2025.01/0001-Add-config-for-the-orangepi-5b-board.patch
      ];
      extraMeta = {
        platforms = [ "aarch64-linux" ];
        license = pkgs-stable.lib.licenses.unfreeRedistributableFirmware;
      };
    };
in
{
  uBootQuartz64A = buildRK3566UBoot { defconfig = "quartz64-a-rk3566_defconfig"; };
  uBootQuartz64B = buildRK3566UBoot { defconfig = "quartz64-b-rk3566_defconfig"; };
  uBootSoQuartzBlade = buildRK3566UBoot {
    defconfig = "soquartz-blade-rk3566_defconfig";
    spi = false;
  };
  uBootSoQuartzCM4IO = buildRK3566UBoot {
    defconfig = "soquartz-cm4-rk3566_defconfig";
    spi = false;
  };
  uBootSoQuartzModelA = buildRK3566UBoot {
    defconfig = "soquartz-model-a-rk3566_defconfig";
    spi = false;
  };
  uBootPineTab2 = buildRK3566UBoot { defconfig = "pinetab2-rk3566_defconfig"; };
  uBootPinebookPro = buildRK3399UBoot "pinebook-pro-rk3399_defconfig";
  uBootRockPro64 = buildRK3399UBoot "rockpro64-rk3399_defconfig";
  uBootROCPCRK3399 = buildRK3399UBoot "roc-pc-rk3399_defconfig";
  uBootRock64 = buildRK3328UBoot "rock64-rk3328_defconfig";
  uBootOrangePiCM4 = buildRK3566UBoot { defconfig = "orangepi-3b-rk3566_defconfig"; };
  uBootOrangePi5B = buildRK3588UBoot "orangepi-5b-rk3588s_defconfig";
  uBootRadxaCM3IO = buildRK3566UBoot {
    defconfig = "radxa-cm3-io-rk3566_defconfig";
    spi = false;
  };
  uBootRadxaRock4 = buildRK3399UBoot "rock-pi-4-rk3399_defconfig";
  uBootRadxaRock4SE = buildRK3399UBoot "rock-4se-rk3399_defconfig";
  uBootRadxaRock4CPlus = buildRK3399UBoot "rock-4c-plus-rk3399_defconfig";
  uBootNanoPCT6 = buildRK3588UBoot "nanopc-t6-rk3588_defconfig";
}
