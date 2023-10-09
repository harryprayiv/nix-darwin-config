{baseDir}: let
  extDir = "${baseDir}/External Extensions/";

  x = import ./extensions.nix;

  ext = builtins.toJSON {
    external_update_url = "https://clients2.google.com/service/update2/crx";
  };
in {
  # see brave.browser.enabled_labs_experiments for more flags
  #xdg.configFile."${baseDir}/Local State".source = ./local-state.json;

  xdg.configFile."${extDir}${x.dark-reader}.json".text = ext;
  xdg.configFile."${extDir}${x.github-dark-theme}.json".text = ext;
  xdg.configFile."${extDir}${x.google-translate}.json".text = ext;
  xdg.configFile."${extDir}${x.keepassxc-browser}.json".text = ext;
  xdg.configFile."${extDir}${x.reddit-enhancement-suite}.json".text = ext;
  xdg.configFile."${extDir}${x.eternl}.json".text = ext;
  xdg.configFile."${extDir}${x.nitter-redirect}.json".text = ext;
  xdg.configFile."${extDir}${x.mastodon-link}.json".text = ext;
  xdg.configFile."${extDir}${x.lace}.json".text = ext;
  #xdg.configFile."${extDir}${x.yoroi}.json".text   = ext;
  #xdg.configFile."${extDir}${x.nami}.json".text   = ext;
  #xdg.configFile."${extDir}${x.gerowallet}.json".text   = ext;
}
