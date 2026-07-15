{ config, pkgs, ... }:

{
  services = {
    easyeffects.enable = true;

    swayidle = {
      enable = true;
      events = {
        before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
        after-resume = "sleep 1; ${pkgs.sway}/bin/swaymsg 'output * power off'; sleep 2; ${pkgs.sway}/bin/swaymsg 'output * power on'; ${pkgs.kanshi}/bin/kanshictl reload";
      };
    };

    kanshi = {
      enable = true;
      settings = [
        {
          profile = {
            name = "desktop-default";
            outputs = [
              {
                criteria = "LG Electronics 27GK750F 0x0004F6EE";
                status = "enable";
                mode = "1920x1080@120.040Hz";
                transform = "90";
                position = "0,0";
              }
              {
                criteria = "LG Electronics LG ULTRAGEAR 309MAPNFF848";
                status = "enable";
                mode = "2560x1440@179.960Hz";
                position = "1080,550";
              }
            ];
          };
        }
        {
          profile = {
            name = "laptop-default";
            outputs = [
              {
                criteria = "eDP-1";
                status = "enable";
                mode = "1920x1080@60.052Hz";
                position = "0,0";
              }
            ];
          };
        }
      ];
    };

    recoll = {
      enable = true;
    };
  };

  programs.mangohud = {
    enable = true;
    settings = {
      gpu_temp = true;
      cpu_temp = true;
      throttling_status = true;
      fps_limit = 180;
      fps_limit_method = "late";
    };
  };

  home.packages = with pkgs; [
    android-tools
    ani-cli
    audiosource
    easyeffects
    espeak
  ];
}
