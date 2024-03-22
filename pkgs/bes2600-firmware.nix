{ fetchFromGitLab, lib, stdenv }:

stdenv.mkDerivation {
  pname = "bes2600-firmware";
  version = "";

  src = fetchFromGitLab {
    owner = "pine64-org";
    repo = "bes2600-firmware";
    rev = "7a305de61771a84f1264866b204cf172df6d9195";
    sha256 = "32O0f0d90n0PW1y8ITvKlLJcKTR3gvaq/c1cKoog98Q=";
  };

  buildPhase = ''
    mkdir -p $out/lib/firmware
    mv firmware/bes2600 $out/lib/firmware
  '';

  meta = with lib; {
    description = "bes2600 firmware";
    homepage = "https://gitlab.com/pine64-org/bes2600-firmware";
    license = licenses.unfree;
  };
}
