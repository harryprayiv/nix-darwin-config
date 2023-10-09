{pkgs, ...}: let
  # obtained via `autorandr --fingerprint`
  towerId = "00ffffffffffff004cd8000101000000081c010380331d782ed945a2554da027125054bfef80b300a9409500904081808140714f0101023a801871382d40582c4500501d7400001e011d007251d01e206e285500c48e2100001e000000fd00184c0f531201000a2020202020000000fc00534658324b382034544f3200000147020328f44d901f041305142021220312071623097f07830100006a030c001400b82d0f0800e200cf023a801871382d40582c4500501d7400001e011d007251d01e206e285500c48e2100001e011d8018711c1620582c2500c48e2100009e8c0ad08a20e02d10103e9600138e2100001800000000000000000000000000000073";
  nucId = "00ffffffffffff004cd8000101000000081c010380301b782ec585a459499a24125054bfef8081c08140714f81800101010181000101023a801871382d40582c4500501d7400001e011d007251d01e206e285500c48e2100001e000000fd00384c1e521001000a2020202020000000fc00534658324b382034544f3200000136020351f2505d5e5f901f041305142021220312071623097f07830100006e030c001100b83c2f888001020304e200cfe305e300e3060f01f90146d00003b8ab50af45a4d0260d145054670ba12c0000000004740030f2705a80b0588a00501d7400001e023a801871382d40582c4500501d7400001e00000000000000000000ed";
  uhdId = "00ffffffffffff003669a23d010101011c1d010380462778eef8c5a556509e26115054bfef80714f81c08100814081809500b300a9404dd000a0f0703e8030203500bc862100001e000000fd001e4b1f873c000a202020202020000000fc004d4147333231435552560a2020000000ff0044413241303139323830303430012c020346f153010203040510111213141f2021225d5e5f616023091707830100006d030c001000383c20006003020167d85dc401788003e40f000006e305e301e60607015c5c0004740030f2705a80b0588a00bc862100001e565e00a0a0a0295030203500bc862100001e1b2150a051001e3048883500bc862100001e0000002f";

  notify = "${pkgs.libnotify}/bin/notify-send";
in {
  programs.autorandr = {
    enable = true;

    hooks = {
      predetect = {};

      preswitch = {};

      postswitch = {
        "notify-xmonad" = ''
          ${notify} -i display "Display profile" "$AUTORANDR_CURRENT_PROFILE"
        '';

        "change-dpi" = ''
          case "$AUTORANDR_CURRENT_PROFILE" in
            intelTower)
              DPI=96
              ;;
            intelNUC)
              DPI=96
              ;;
            uHD)
              DPI=120
              ;;
            *)
              ${notify} -i display "Unknown profle: $AUTORANDR_CURRENT_PROFILE"
              exit 1
          esac

          echo "Xft.dpi: $DPI" | ${pkgs.xorg.xrdb}/bin/xrdb -merge
        '';
      };
    };

    profiles = {
      "intelTower" = {
        fingerprint = {
          HDMI-2 = towerId;
        };
        config = {
          HDMI-2 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "60.04";
            rotate = "normal";
          };
        };
      };

      "intelNUC" = {
        fingerprint = {
          HDMI-1 = nucId;
        };

        config = {
          HDMI-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "60.04";
            rotate = "normal";
          };
        };
      };
      "uHD" = {
        fingerprint = {
          HDMI-1 = uhdId;
        };

        config = {
          HDMI-1 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "3840x2160";
            rate = "60.04";
            rotate = "normal";
          };
        };
      };
    };
  };
}
