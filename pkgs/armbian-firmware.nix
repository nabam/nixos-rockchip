{ pkgs, lib, fetchFromGitHub, runCommand, stdenv }:
let
  armbian-firmware-src = fetchFromGitHub {
    owner = "armbian";
    repo = "firmware";
    rev = "7d04f88c37b7c6b9f88b01b0ceb51fea642ece40";
    sha256 = "4R8We7U7GD2rw4w37bdmAUnRS9O1iS5QXop33a8w/qI=";
  };
  to-firmware-pkg = { pname, description, paths, config }:
    let
      copy-cmd = src: dest: ''
        dest_dir=$(dirname ${dest})
        mkdir -p "$out/lib/firmware/$dest_dir"
        cp -r $src/${src} "$out/lib/firmware/${dest}"
      '';
      copy-cmd-set = { src, dests, ... }:
        lib.concatLines (map (copy-cmd src) dests);
      copy-cmd-spec = spec:
        if builtins.typeOf spec == "string" then
          copy-cmd spec spec
        else
          copy-cmd-set spec;
      copy-cmds = lib.concatLines (map copy-cmd-spec paths);
      config-file = pkgs.writeTextFile {
        name = "config.txt";
        text = config;
      };
    in stdenv.mkDerivation rec {
      inherit pname;
      version = "1.0";
      meta = with lib; {
        inherit description;
        license = licenses.unfree;
        homepage = "https://github.com/armbian/firmware";
      };
      src = armbian-firmware-src;
      dontBuild = true;
      installPhase = ''
        mkdir -p "$out/lib/firmware"
        ${copy-cmds}
        cp ${config-file} $out/lib/firmware/brcm/config.txt
      '';
    };
in {
  armbian-firmware = stdenv.mkDerivation rec {
    pname = "armbian-firmware";
    description = "Propietary firmwares included with armbian";
    version = "1.0";
    meta = with lib; {
      inherit description;
      license = licenses.unfree;
      homepage = "https://github.com/armbian/firmware";
    };
    src = armbian-firmware-src;
    dontBuild = true;
    installPhase = ''
      mkdir -p "$out/lib/firmware"
      cp -r ${src}/* $out/lib/firmware
    '';
  };
  brcm-43752-pcie = to-firmware-pkg {
    pname = "brcmfmac-firmware";
    description = "Propietary firmware for broadcomm devices";
    paths = [
      "brcm/nvram_ap6275s.txt"
      {
        src = "brcm/brcmfmac43752-pcie.txt";
        dests = [
          "brcm/brcmfmac43752-pcie.txt"
          "brcm/brcmfmac43752-pcie.xunlong,orangepi-5b.txt"
        ];
      }
      {
        src = "brcm/brcmfmac43752-pcie.clm_blob";
        dests = [
          "brcm/brcmfmac43752-pcie.clm_blob"
          "brcm/brcmfmac43752-pcie.xunlong,orangepi-5b.clm_blob"
        ];
      }
      {
        src = "brcm/brcmfmac43752-pcie.bin";
        dests = [
          "brcm/brcmfmac43752-pcie.bin"
          "brcm/brcmfmac43752-pcie.xunlong,orangepi-5b.bin"
        ];
      }
    ];
    config = ''
      PM=0
      kso_enable=0
      ccode=CN
      regrev=38
      nv_by_chip=1 \
      43362 1 nvram_ap6210.txt \
      43430 0 nvram_ap6212.txt \
      43430 1 nvram_ap6212a.txt \
      17221 6 nvram_ap6255.txt  \
      17236 2 nvram_ap6356.txt \
      17241 9 nvram_ap6359sa.txt \
      43752 2 nvram_ap6275s.txt
    '';
  };
}
