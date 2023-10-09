{pkgs, ...}: {
  services.picom = {
    enable = true;
    backend = "glx";
    activeOpacity = 0.92;
    inactiveOpacity = 0.80;
    settings = {
      corner-radius = 8;
      round-borders = 2;
      blur-method = "dual_kawase";
      blur-strength = "5";
    };
    opacityRules = ["100:name *= 'i3lock'"];
    fade = true;
    fadeDelta = 5;
    vSync = true;
    shadow = true;
    shadowOpacity = 0.95;
    shadowExclude = [
      "bounding_shaped && !rounded_corners"
    ];
    package = pkgs.picom.overrideAttrs (o: {
      src = pkgs.fetchFromGitHub {
        repo = "picom";
        owner = "ibhagwan";
        rev = "c4107bb6cc17773fdc6c48bb2e475ef957513c7a";
        sha256 = "1hVFBGo4Ieke2T9PqMur1w4D0bz/L3FAvfujY9Zergw=";
      };
    });
  };
}
/*
used nix-prefetch-github ibhagwan picom to find latest commit sha256
  rev = "c4107bb6cc17773fdc6c48bb2e475ef957513c7a";
  sha256 = "1hVFBGo4Ieke2T9PqMur1w4D0bz/L3FAvfujY9Zergw=";

old working revsion/sha256
  rev = "44b4970f70d6b23759a61a2b94d9bfb4351b41b1";
  sha256 = "0iff4bwpc00xbjad0m000midslgx12aihs33mdvfckr75r114ylh";
*/

