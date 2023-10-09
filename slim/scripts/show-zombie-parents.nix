{pkgs, ...}:
# https://www.linkedin.com/pulse/how-identify-kill-zombiedefunct-processes-linux-without-george-gabra/
pkgs.writeShellScriptBin "szp" ''
  ps -A -ostat,ppid | grep -e '[zZ]'| awk '{ print $2 }' | uniq | xargs ps -p
''
