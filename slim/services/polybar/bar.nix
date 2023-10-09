{
  font0 ? 16,
  font1 ? 18,
  font2 ? 40,
  font3 ? 28,
  font4 ? 7,
  font5 ? 16,
  font6 ? 18,
  font7 ? 10,
  font8 ? 16,
}: let
  bar = ''
    [bar/main]
    monitor = ''${env:MONITOR:HDMI-2}
    width = 100%
    height = 30
    radius = 0.0
    fixed-center = true

    background = ''${color.bg}
    foreground = ''${color.fg}

    padding-left = 2
    padding-right = 2

    module-margin-left = 1
    module-margin-right = 1

    tray-padding = 8
    tray-background = ''${color.bg}

    cursor-click = pointer
    cursor-scroll = ns-resize

    overline-size = 1
    overline-color = ''${color.ac}

    border-bottom-size = 0
    border-color = ''${color.ac}

    ; Text Fonts
    font-0 = Iosevka Nerd Font:style=Medium:size=${toString font0};3
    ; Icons Fonts
    font-1 = icomoon\\-feather:style=Medium:size=${toString font1};3
    ; Powerline Glyphs
    font-2 = Iosevka Nerd Font:style=Medium:size=${toString font2};3
    ; Larger font size for bar fill icons
    font-3 = Iosevka Nerd Font:style=Medium:size=${toString font3};3
    ; Smaller font size for shorter spaces
    font-4 = Iosevka Nerd Font:style=Medium:size=${toString font4};3
    ; Keyboard layout icons
    font-5 = FlagsWorldColor:size=${toString font5}:antialias=false;3
    ; Larger font size for crypto bar fill icons
    font-6 = cardanofont:style=Medium:size=${toString font6};3
    ; Smaller font size for crypto bar fill icons
    font-7 = cardanofont:style=Medium:size=${toString font7};3
    ; Smaller font size for crypto bar fill icons
    font-8 = FiraCode-Medium:style=Medium:size=${toString font8};3

    ;font-5 = "MaterialIcons:size=40;0"
    ;font-6 = Font Awesome 5 Free:style=Solid:pixelsize=20;3
    ;font-5 = Unifont:size=64:antialias=false;1
  '';

  top = ''
    [bar/top]
    inherit = bar/main

    tray-position = none
    modules-left = cardano xmonad
    modules-right = mpris clickable-date
    enable-ipc = true
  '';

  bottom = ''
    [bar/bottom]
    inherit = bar/main
    bottom = true

    tray-position = center
    modules-left =  cnodeStatus fngi ada cpu temperature memory filesystem
    modules-right = wired-network  clickable-keyboard pulseaudio powermenu
    enable-ipc = true
  '';
in
  bar + top + bottom
