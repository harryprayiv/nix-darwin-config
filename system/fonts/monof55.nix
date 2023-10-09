{
  stdenv,
  lib,
}:
stdenv.mkDerivation {
  name = "Monofur";
  src = ./monof55.ttf;

  phases = ["installPhase"];

  installPhase = ''
    install -D $src $out/share/fonts/truetype/monof55.ttf
  '';
}
