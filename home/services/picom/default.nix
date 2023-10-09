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
      rounded-corners-exclude = ["window_type *= 'dock'"];
    };
    opacityRules = [
      "100:name *= 'i3lock'"
      "100:window_type *= 'dock'"
    ];
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
