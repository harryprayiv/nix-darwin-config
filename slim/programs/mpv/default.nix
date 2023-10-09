{pkgs, ...}: {
  programs.mpv = {
    enable = true;
    #profile = "gpu-hq";
    #force-window = true;
    #ytdl-format = "bestvideo+bestaudio";
    #cache-default = 4000000;
  };
}
