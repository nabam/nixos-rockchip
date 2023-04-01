{ pkgs, stdenv, lib, fetchpatch, fetchFromGitHub, buildUBoot }:

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
      sha256 = "gwI8yrgf6gzRYA0pVQbNp9/GtEw40Yx7HZL6JYyle9M=";
    };
    version = "v2023.04-rc1-20-gbe645fef05";
  in buildUBoot {
    src = src;
    version = version;
    defconfig = defconfig;
    filesToInstall = [ "u-boot.itb" "idbloader.img"];

    patches = [
      (fetchpatch {
        name = "quartz64.patch";
        url = "https://github.com/CounterPillow/u-boot-quartz64/compare/v2023.04-rc1...be645fef058885e2fc9882e839dacd6941693ac6.diff";
        sha256 = "yrieWMadb2I3mK7XCh+byeVUuxMg4JaPp5L7JxKyueA=";
      })
    ];

    preConfigure = ''
      touch board/pine64/quartz64-a-rk3566/quartz64-a-rk3566.c # required empty file, not created from patch
    '';

    buildInputs = with pkgs; [
      openssl # for cross-compilation

      ncurses # tools/kwboot
      libuuid # tools/mkeficapsule
      gnutls # tools/mkeficapsule
    ];

    nativeBuildInputs = with pkgs; [
      ncurses # tools/kwboot
      bc
      bison
      dtc
      flex
      openssl
      (buildPackages.python3.withPackages (p: [
        p.libfdt
        p.setuptools # for pkg_resources
        p.pyelftools
      ]))
      swig
      which # for scripts/dtc-version.sh
    ];

    BL31 = (rkbin + "/bin/rk35/rk3568_bl31_v1.34.elf");
    ROCKCHIP_TPL = (rkbin + "/bin/rk35/rk3566_ddr_1056MHz_v1.13.bin");

    extraMeta = {
      platforms = [ "aarch64-linux" ];
      license = lib.licenses.unfreeRedistributableFirmware;
    };
  };
  buildRK3566UBoot_2022_04 = defconfig: let
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
      rev = "v2022.04-rc1";
      sha256 = "grFRNvr/Z5tQxqj/16q3JpD/ncLozdqSKfYZqa1SGzg=";
    };
    version = "v2022.04-rc1-quartz64-2ea8c1c";
  in buildUBoot {
    src = src;
    version = version;
    defconfig = defconfig;
    extraMakeFlags = [ "all" "u-boot.itb" ];
    filesToInstall = [ "u-boot.itb" "idbloader.img"];

    patches = [
      (fetchpatch {
        name = "quartz64.patch";
        url = "https://github.com/CounterPillow/u-boot-quartz64/compare/df887a045a1d726bbd654ef266e5cbe8cc0c2db3...2ea8c1c4db6d739273ae3821970c02e9d3b6180b.diff";
        sha256 = "tA0wuallJVoA585zpGWywQco/iBKQMBBKH4ReXme8Uc=";
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
  uBootQuartz64A      = buildRK3566UBoot "quartz64-a-rk3566_defconfig";
  uBootQuartz64B      = buildRK3566UBoot "quartz64-b-rk3566_defconfig";
  uBootSoQuartzBlade  = buildRK3566UBoot "soquartz-blade-rk3566_defconfig";
  uBootSoQuartzCM4IO  = buildRK3566UBoot "soquartz-cm4io-rk3566_defconfig";
  uBootSoQuartzModelA = buildRK3566UBoot "soquartz-model-a-rk3566_defconfig";

  uBootQuartz64A_2022_04 = buildRK3566UBoot_2022_04 "quartz64-a-rk3566_defconfig";
  uBootQuartz64B_2022_04 = buildRK3566UBoot_2022_04 "quartz64-b-rk3566_defconfig";
  uBootSoQuartz_2022_04  = buildRK3566UBoot_2022_04 "soquartz-rk3566_defconfig";
}
