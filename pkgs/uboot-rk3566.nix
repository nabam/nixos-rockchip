{ stdenv, lib, fetchpatch, fetchFromGitHub, buildUBoot }:

let
  rkbin = fetchFromGitHub {
    owner = "rockchip-linux";
    repo = "rkbin";
    rev = "b0c100f1a260d807df450019774993c761beb79d";
    sha256 = "V7RcQj3BgB2q6Lgw5RfcPlOTZF8dbC9beZBUsTvaky0=";
  };
  src = fetchFromGitHub {
    owner = "rockchip-linux";
    repo = "u-boot";
    rev = "ef1dd650042f61915c4859ecc94623a09a3529fa";
    sha256 = "w0hp1UGxCtSBlu9YJx6KUjeHfPCB+QqoNDlLp7AshoM=";
  };
  version = "2017.09-rockchip-linux-ef1dd65";
in buildUBoot {
  src = src;
  version = version;
  defconfig = "rk3566-quartz64_defconfig";
  extraMakeFlags = [ "all" "u-boot.itb" ];
  filesToInstall = [ "u-boot.itb" "idbloader.img"];

  patches = [
    (fetchpatch {
      name = "add-board-quartz64.patch";
      url = "https://gitlab.com/sndwvs/images_build_kit/-/raw/1e7e9047748bfec71d824cbcb7426391bd0ed3e9/patch/u-boot/rk3588/add-board-quartz64.patch?inline=false";
      sha256 = "izR0xTqUGCf+Bls7NEbbL3l8qA7tlAGls6/6B/IcB5U=";
    })
  ];

  preConfigure = ''
      ln -sf ${rkbin}/bin/rk35/rk3568_bl31_v1.34.elf ./bl31.elf
      ln -sf ${rkbin}/bin/rk35/rk3568_bl32_v2.08.bin ./tee.bin
  '';
  postBuild = ''
      ./tools/mkimage -n rk3568 -T rksd -d ${rkbin}/bin/rk35/rk3566_ddr_1056MHz_v1.13.bin:spl/u-boot-spl.bin idbloader.img
  '';

  extraMeta = {
    platforms = [ "aarch64-linux" ];
    license = lib.licenses.unfreeRedistributableFirmware;
  };
}
