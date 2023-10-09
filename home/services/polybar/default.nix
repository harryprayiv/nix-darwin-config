{
  config,
  pkgs,
  specialArgs,
  inputs,
  ...
}: let
  browser = "${pkgs.brave}/bin/brave";

  terminal = "${pkgs.alacritty}/bin/alacritty";

  openCalendar = "${pkgs.xfce.orage}/bin/orage";

  uhdBar = pkgs.callPackage ./bar.nix {};

  hdBar = pkgs.callPackage ./bar.nix {
    font0 = 10;
    font1 = 12;
    font2 = 15;
    font3 = 14;
    font4 = 5;
    font5 = 10;
    font6 = 14;
    font7 = 8;
    font8 = 12;
  };

  mainBar =
    if specialArgs.ultraHD
    then uhdBar
    else hdBar;

  xdgUtils = pkgs.xdg-utils.overrideAttrs (
    old: {
      nativeBuildInputs = old.nativeBuildInputs or [] ++ [pkgs.makeWrapper];
      postInstall =
        old.postInstall
        + "\n"
        + ''
          wrapProgram $out/bin/xdg-open --suffix PATH : /run/current-system/sw/bin --suffix BROWSER : ${browser}
        '';
    }
  );

  openGithub = "${xdgUtils}/bin/xdg-open https\\://github.com/notifications";
  openFearandGreed = "${xdgUtils}/bin/xdg-open https\\://alternative.me/crypto/fear-and-greed-index/";
  openCardanoSublemmy = "${xdgUtils}/bin/xdg-open https\\://infosec.pub/c/cardano/";

  mypolybar = pkgs.polybar.override {
    alsaSupport = true;
    githubSupport = true;
    mpdSupport = true;
    pulseSupport = true;
  };

  # theme adapted from: https://github.com/adi1090x/polybar-themes#-polybar-5
  bars = builtins.readFile ./bars.ini;
  colors = builtins.readFile ./colors.ini;
  mods1 = builtins.readFile ./modules.ini;
  mods2 = builtins.readFile ./user_modules.ini;

  bluetoothScript = pkgs.callPackage ./scripts/bluetooth.nix {};
  klsScript = pkgs.callPackage ../../scripts/keyboard-layout-switch.nix {inherit pkgs;};
  monitorScript = pkgs.callPackage ./scripts/monitor.nix {};
  mprisScript = pkgs.callPackage ./scripts/mpris.nix {};
  networkScript = pkgs.callPackage ./scripts/network.nix {};
  vpnToggleScript = pkgs.callPackage ../../scripts/vpn.nix {inherit pkgs;};
  vpnStatus = pkgs.callPackage ./scripts/vpnStatus.nix {};
  fgindexScript = pkgs.callPackage ./scripts/fngi.nix {};
  adaScript = pkgs.callPackage ./scripts/ada.nix {};
  cnodeStatusScript = pkgs.callPackage ./scripts/cnodeStatus.nix {};
  cnodeToggleScript = pkgs.callPackage ../../scripts/node_toggle.nix {inherit inputs pkgs config;};

  bctl = ''
    [module/bctl]
    type = custom/script
    exec = ${bluetoothScript}/bin/bluetooth-ctl
    tail = true
    click-left = ${bluetoothScript}/bin/bluetooth-ctl --toggle &
  '';

  cal = ''
    [module/clickable-date]
    inherit = module/date
    label = %{A1:${openCalendar}:}%time%%{A}
  '';

  github = ''
    [module/clickable-github]
    inherit = module/github
    token = ''${file:${config.xdg.configHome}/secrets/github}
    user = bismuth
    label = %{A1:${openGithub}:}  %notifications%%{A}
  '';

  keyboard = ''
    [module/clickable-keyboard]
    inherit = module/keyboard
    label-layout = %{A1:${klsScript}/bin/kls:}  %layout% %icon% %{A}
  '';

  mpris = ''
    [module/mpris]
    type = custom/script

    exec = ${mprisScript}/bin/mpris
    tail = true

    label-maxlen = 50

    interval = 2
    format =   <label>
    format-padding = 2
  '';

  fngi = ''
    [module/fngi]
    type = custom/script

    exec = ${fgindexScript}/bin/fngi

    label-maxlen = 20

    interval = 10800
    format-padding = 1

    format = "%{T3}%{T-}<label>"


    # ramp-0 = %{F#999}<label>%{F-}
    # ramp-1 = %{F#900}<label>%{F-}
    # ramp-50 = %{F#F00}<label>%{F-}
    click-left = ${openFearandGreed}
  '';

  ada = ''
    [module/ada]
    type = custom/script

    exec = ${adaScript}/bin/ada


    label-maxlen = 10

    interval = 120
    format = "%{T2}₳%{T-} <label>"
    format-padding = 0
    click-left = ${openCardanoSublemmy}
  '';

  cnodeStatus = ''
    [module/cnodeStatus]
    type = custom/script

    exec = ${cnodeStatusScript}/bin/cnodeStatus

    interval = 4
    format = "%{T7}<label>"
    content-foreground = ''${color.lbshade4}
    format-padding = 0
    click-left = "${terminal} --hold -e ${cnodeToggleScript}/bin/node_toggle"
  '';

  vpn = ''
    [module/vpn]
    type = custom/script

    exec = ${vpnStatus}/bin/vpn_status

    interval = 4
    format = "%{T7}<label>"
    content-foreground = ''${color.lbshade4}
    format-padding = 0
    click-left = "${terminal} --hold -e ${vpnToggleScript}/bin/vpn"
  '';

  xmonad = ''
    [module/xmonad]
    type = custom/script
    exec = ${pkgs.xmonad-log}/bin/xmonad-log
    label-maxlen = 318
    tail = true
  '';

  customMods = mainBar + bctl + cal + github + keyboard + mpris + xmonad + fngi + ada + cnodeStatus + vpn;
in {
  home.packages = with pkgs; [
    font-awesome # awesome fonts
    material-design-icons # fonts with glyphs
    xfce.orage # lightweight calendar
    # inputs.cardano-node.packages.x86_64-linux.cardano-node
  ];

  services.polybar = {
    enable = true;
    package = mypolybar;
    config = ./config.ini;
    extraConfig = bars + colors + mods1 + mods2 + customMods;
    script = ''
      export MONITOR=$(${monitorScript}/bin/monitor)
      echo "Running polybar on $MONITOR"
      export ETH_INTERFACE=$(${networkScript}/bin/check-network eth)
      export WIFI_INTERFACE=$(${networkScript}/bin/check-network wifi)
      echo "Network interfaces $ETH_INTERFACE & $WIFI_INTERFACE"
      polybar top 2>${config.xdg.configHome}/polybar/logs/top.log & disown
      polybar bottom 2>${config.xdg.configHome}/polybar/logs/bottom.log & disown
    '';
  };
}
