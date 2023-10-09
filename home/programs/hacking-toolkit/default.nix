{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  hackerPkgs = with pkgs; [
    # Offensive Tools and Applications
    nmap
    crackmapexec
    gobuster
    theharvester
    ffuf
    wfuzz
    metasploit
    exploitdb
    sqlmap
    smbmap
    arp-scan
    enum4linux
    enum4linux-ng
    dnsrecon
    testssl
    hashcat
    john
    thc-hydra
    whatweb
    evil-winrm
    crunch
    hashcat-utils
    cadaver
    wpscan
    adreaper
    certipy
    coercer
    gomapenum
    kerbrute
    nbtscanner
    smbscan
    davtest
    adenum
    proxychains-ng
    responder
    qFlipper
  ];
in {
  home.packages = hackerPkgs;
}
