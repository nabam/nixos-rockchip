{ config, pkgs, lib, modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/base.nix")
    (modulesPath + "/installer/sd-card/sd-image.nix")
  ];

  options = { rockchip.uBoot = lib.mkOption { }; };

  config.boot = {
    consoleLogLevel = lib.mkDefault 7;
    kernelPackages = lib.mkDefault
      (pkgs.callPackage ../../pkgs/linux-rockchip.nix { }).linux_6_6;

    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  config.sdImage = let
    uBoot = config.rockchip.uBoot;

    idbloaderOffset = 64; # 0x40
    ubootOffset = 16384; # 0x4000
    # 1.7Mb at the moment; use very safe security margin of 8MB.
    ubootSize = 16384; # 8mb
  in {
    compressImage = false;

    # Override expansion script built into sd-image.nix module as it fails to identify partition number correctly
    expandOnBoot = false;

    # Module sd-image.nix always creates special firmware partition for RPi,
    # replace firmware partition with U-Boot after the image is ready.
    firmwarePartitionOffset = ubootOffset / 2048;
    firmwareSize = ubootSize / 2048;
    populateFirmwareCommands = "";
    # Overwrite firmware partition with u-boot bootloader
    postBuildCommands = ''
      sfdisk --part-type "$img" 1 DA # mark partition as "Non-FS data"
      if [ -e "${uBoot}/u-boot-rockchip.bin" ]; then
        # u-boot-rockchip.bin contains both idbloader and uboot
        dd if="${uBoot}/u-boot-rockchip.bin" of="$img" conv=fsync,notrunc bs=16M seek=${
          toString (idbloaderOffset * 512)
        } iflag=direct,count_bytes,skip_bytes oflag=direct,seek_bytes
      else
        dd if="${uBoot}/idbloader.img" of="$img" conv=fsync,notrunc bs=16M seek=${
          toString (idbloaderOffset * 512)
        } iflag=direct,count_bytes,skip_bytes oflag=direct,seek_bytes
        dd if="${uBoot}/u-boot.itb" of="$img" conv=fsync,notrunc bs=16M seek=${
          toString (ubootOffset * 512)
        } iflag=direct,count_bytes,skip_bytes oflag=direct,seek_bytes
      fi
      sfdisk -d "$img"
    '';
    # Fill the root partition with this nix configuration in /etc/nixos
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };

  # Override commands from sd-image.nix module as it fails to identify partition number correctly
  config.boot.postBootCommands = lib.mkBefore ''
    # On the first boot do some maintenance tasks
    if [ -f /nix-path-registration ]; then
      set -euo pipefail
      set -x
      # Figure out device names for the boot device and root filesystem.
      rootPart=$(${pkgs.util-linux}/bin/findmnt -n -o SOURCE /)
      bootDevice=$(lsblk -npo PKNAME $rootPart)
      partNum=2 # HARDCODED

      # Resize the root partition and the filesystem to fit the disk
      echo ",+," | sfdisk -N$partNum --no-reread $bootDevice
      ${pkgs.parted}/bin/partprobe
      ${pkgs.e2fsprogs}/bin/resize2fs $rootPart

      # Register the contents of the initial Nix store
      ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration

      # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
      touch /etc/NIXOS
      ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system

      # Prevents this from running on later boots.
      rm -f /nix-path-registration
    fi
  '';
}

