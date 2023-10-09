{
  stdenv,
  lib,
}:
stdenv.mkDerivation {
  name = "cardanofont";
  src = ./cardanofont.ttf;

  phases = ["installPhase"];

  installPhase = ''
    install -D $src $out/share/fonts/truetype/cardanofont.ttf
  '';
}
