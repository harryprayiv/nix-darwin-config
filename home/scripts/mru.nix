{pkgs, ...}:
pkgs.writeShellScriptBin "mru" ''
  cd ~
  mr u -j5
''
