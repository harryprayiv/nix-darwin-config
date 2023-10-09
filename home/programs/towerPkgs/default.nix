{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cpuHungryPkgs = with pkgs; [
    vlc # media player
    darktable # raw photo manipulation and grading
    mpv # media player
    #kodi                 # media player
    gimp # gnu image manipulation program (I started using gimp 2.99 which is causing problems with this one)
    # blender              # 3D computer graphics software tool set
    krita # image editor (supposedly better than gimp)
    mkvtoolnix # tools for encoding MKV files, etc
    filebot # batch renaming
    kdenlive # super nice video editor
    mlt # kdenlive uses the MLT framework to process all video operations
    mediainfo # additional package for kdenlive
    inkscape # absolutely essential for editing Typefaces and Fonts
    scribus # Open source alternative to Indesign and Quark
    sqlite # sql lite databse
    drawio # diagram design
    obsidian # note taking/mind mapping
    #libreoffice          # office suite
  ];

  homePkgs = with pkgs; [
    # hue-cli # lights for my residence
    mr # mass github actions
  ];
in {
  home.packages = homePkgs ++ cpuHungryPkgs;
}
