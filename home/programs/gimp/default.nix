{pkgs, ...}: {
  gimp = {
    enable = true;
    package = pkgs.gimp.overrideAttrs (o: {
      src = pkgs.fetchFromGitHub {
        # repo = "gimp";
        # owner = "ibhagwan";
        # rev = "c4107bb6cc17773fdc6c48bb2e475ef957513c7a";
        # sha256 = "1hVFBGo4Ieke2T9PqMur1w4D0bz/L3FAvfujY9Zergw=";
      };
    });
  };
}
# nix-build https://github.com/jtojnar/nixpkgs/archive/gimp-meson.tar.gz -A gimp
/*
used nix-prefetch-github ibhagwan picom to find latest commit sha256
  rev = "c4107bb6cc17773fdc6c48bb2e475ef957513c7a";
  sha256 = "1hVFBGo4Ieke2T9PqMur1w4D0bz/L3FAvfujY9Zergw=";

old working revsion/sha256
  rev = "44b4970f70d6b23759a61a2b94d9bfb4351b41b1";
  sha256 = "0iff4bwpc00xbjad0m000midslgx12aihs33mdvfckr75r114ylh";
*/

