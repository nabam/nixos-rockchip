{
  fetchFromGitHub,
  fetchFromGitea,
  kernel,
  kernelModuleMakeFlags,
  stdenv,
  lib,
}:

stdenv.mkDerivation rec {
  name = "bes2600";
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "raboof";
    repo = "bes2600";
    rev = "028f51d4100eb3be170903ba26f2497b342dd46d";
    hash = "sha256-kiK31kgQcy+I9dK3J1UNJAIdboHhKkrfwa+2qtU2RdM=";
  };
  sourceRoot = "source/bes2600";
  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERN_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "CONFIG_BES2600=m"
    "CONFIG_BES2600_5GHZ_SUPPORT=y"
    "CONFIG_BES2600_DEBUGFS=y"
    "CONFIG_BES2600_ENABLE_DEVEL_LOGS=y"
    "CONFIG_BES2600_BTUART=m"
  ];
  installPhase = ''
    runHook preInstall
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      INSTALL_MOD_PATH=$out \
      $makeFlags \
      modules_install
    runHook postInstall
  '';

  meta = {
    description = "bes2600 kernel module";
    /*
      This is 'just' the bes2600 module from the
      https://codeberg.org/DanctNIX/linux-pinetab2
      tree but extracted to a separate repo
    */
    homepage = "https://codeberg.org/raboof/bes2600";
    /*
      There is some scary license text in txrx_opt.c
      but that looks like an oversight: it seems
      questionable if this would be copyrightable at
      all (given it's mainly interoperability info)
      and was provided to the community with the goal
      of using it in the module, but the manufacturer
      has been MIA in clarifying this explicitly. Make
      your own judgement.
    */
    license = lib.licenses.gpl2Only;
  };
}
