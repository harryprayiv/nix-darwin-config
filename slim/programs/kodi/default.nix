{pkgs, ...}: {
  programs.kodi = {
    enable = false;
    # withPackages (exts: [ exts.amber-skin ]);
    settings.videolibrary = {
      showemptytvshows = "true";
      recentlyaddeditems = "100";
    };
    sources = {
      video = {
        default = "videos";
        source = [
          {
            name = "Film";
            path = "/home/bismuth/video/_Movies";
            allowsharing = "true";
          }
          {
            name = "New Films (HQ)";
            path = "/home/bismuth/video/_Unsorted/torrents/Complete/AMC/Movies/10bit";
            allowsharing = "true";
          }
          {
            name = "New Films";
            path = "/home/bismuth/video/_Unsorted/torrents/Complete/AMC/Movies/8bit";
            allowsharing = "true";
          }
          {
            name = "Episodic";
            path = "/home/bismuth/video/_Episodic";
            allowsharing = "true";
          }
          {
            name = "New Episodic (HQ)";
            path = "/home/bismuth/video/_Unsorted/torrents/Complete/AMC/Episodic/10bit";
            allowsharing = "true";
          }
          {
            name = "New Episodic";
            path = "/home/bismuth/video/_Unsorted/torrents/Complete/AMC/Episodic/8bit";
            allowsharing = "true";
          }
        ];
      };
    };
  };
}
