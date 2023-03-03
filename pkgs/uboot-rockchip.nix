{ stdenv, lib, fetchpatch, fetchFromGitHub, buildUBoot }:

let 
  buildRK3566UBoot = defconfig: let
    inherit defconfig;
    rkbin = fetchFromGitHub {
      owner = "rockchip-linux";
      repo = "rkbin";
      rev = "b0c100f1a260d807df450019774993c761beb79d";
      sha256 = "V7RcQj3BgB2q6Lgw5RfcPlOTZF8dbC9beZBUsTvaky0=";
    };
    src = fetchFromGitHub {
      owner = "u-boot";
      repo = "u-boot";
      rev = "v2023.04-rc1";
      sha256 = "";
    };
    version = "v2023.04-rc1-quartz64-2ea8c1c";
  in buildUBoot {
    src = src;
    version = version;
    defconfig = defconfig;
    extraMakeFlags = [ "all" "u-boot.itb" ];
    filesToInstall = [ "u-boot.itb" "idbloader.img"];

    patches = [
      (fetchpatch {
        name = "quartz64.patch";
        url = "https://github.com/CounterPillow/u-boot-quartz64/compare/v2023.04-rc1...be645fef058885e2fc9882e839dacd6941693ac6.diff";
        sha256 = "";
      })
    ];

    preConfigure = ''
        ln -sf ${rkbin}/bin/rk35/rk3568_bl31_v1.34.elf ./bl31.elf
        ln -sf ${rkbin}/bin/rk35/rk3566_ddr_1056MHz_v1.13.bin ./ram_init.bin
    '';

    extraMeta = {
      platforms = [ "aarch64-linux" ];
      license = lib.licenses.unfreeRedistributableFirmware;
    };
  };
in {
  uBootQuartz64A = buildRK3566UBoot "quartz64-a-rk3566_defconfig";
  uBootQuartz64B = buildRK3566UBoot "quartz64-b-rk3566_defconfig";
  uBootSoQuartz  = buildRK3566UBoot "soquartz-rk3566_defconfig";
}
