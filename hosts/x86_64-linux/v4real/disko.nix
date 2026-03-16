{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0022"
                  "dmask=0022"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "rootfs";
                settings.allowDiscards = true;
                passwordFile = "/tmp/luks.key";
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress-force=zstd:1"
                        "noatime"
                        "discard=async"
                      ];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = [
                        "compress-force=zstd:1"
                        "noatime"
                        "discard=async"
                      ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress-force=zstd:1"
                        "noatime"
                        "discard=async"
                      ];
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = [
                        "compress-force=zstd:1"
                        "noatime"
                        "discard=async"
                      ];
                    };
                    "@swap" = {
                      mountpoint = "/swap";
                      mountOptions = [
                        "compress=none"
                        "noatime"
                        "discard=async"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
