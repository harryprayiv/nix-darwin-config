{baseDir}: let
  extDir = "${baseDir}/External Extensions/";

  x = import ./extensions.nix;

  ext = builtins.toJSON {
    external_update_url = "https://clients2.google.com/service/update2/crx";
  };
in {
  # see brave.browser.enabled_labs_experiments for more flags
  xdg.configFile."${extDir}${x.keepassxc-browser}.json".text = ext;
  xdg.configFile."${extDir}${x.adblock-for-youtube}.json".text = ext;
  xdg.configFile."${extDir}${x.youtube-shorts-block}.json".text = ext;
  xdg.configFile."${extDir}${x.lace}.json".text = ext;
  xdg.configFile."${extDir}${x.eternl}.json".text = ext;
  xdg.configFile."${extDir}${x.nitter-redirect}.json".text = ext;

  # nitter-redirect = "mohaicophfnifehkkkdbcejkflmgfkof";
  # lace = "gafhhkghbfjjkeiendhlofajokpaflmk";
  # eternl = "kmhcihpebfmpgmihbkipmjlmmioameka";
}
