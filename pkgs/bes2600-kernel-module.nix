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
    rev = "2350a4a44ec3d0f1a1a8df4959410e33372f8603";
    hash = "sha256-fKNjM3nK0Ni13MvkuM3Y5uVmO1b0034RdLrcWt1Rdmk=";
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
