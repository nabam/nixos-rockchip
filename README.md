# NixOS Images for Rockchip Based Computers

Flake to build images for Rockhip based computers that require custom uboot
firmware. Utilizes sd-card installer build infrastructure from nixpkgs.

## Keep in Mind

- **Automatic PineTab 2 builds are temporarily disabled due to lack of a patch for kernel 6.16.** Latest release for the Pinetab 2 is
  [v25.05.20250817.48f4c98](https://github.com/nabam/nixos-rockchip/releases/tag/v25.05.20250817.48f4c98)
- Flakes are automaticaly updated every Monday. Because of that latest comming in maim brunch may be broken. 
  Check out a tag associated with the latest [release](https://github.com/nabam/nixos-rockchip/releases) if you are looking for a tested revision of the flake.

## Image Building

### Installer

Check out `flake.nix` for the list of supported configurations. To build an
installer sd-card image for desired platform using flake execute 
`nix build github:nabam/nixos-rockchip#Quartz64A` or `nix build .#Quartz64A`
(Quartz 64 A in this example).

``` console
$ nix build github:nabam/nixos-rockchip#Quartz64A
$ sfdisk --dump result/sd-image/nixos-image-sd-card-*.img
label: dos
label-id: 0x2178694e
device: result/sd-image/nixos-image-sd-card-XXX-aarch64-linux.img
unit: sectors
sector-size: 512

result/sd-image/nixos-image-sd-card-XXX-aarch64-linux.img1 : start=       16384, size=       16384, type=da
result/sd-image/nixos-image-sd-card-XXX-aarch64-linux.img2 : start=       32768, size=     5585984, type=83, bootable
```

Built image then can be copied to sdcard or other memory:

``` console
$ sudo dd if=./result/sd-image/nixos-image-sd-card-*.img of=/dev/mmcblk0 iflag=direct oflag=direct bs=16M status=progress
```

To build all images run:
``` console
nix build .#Quartz64A .#Quartz64B .#SoQuartzModelA .#SoQuartzCM4 .#SoQuartzBlade .#Rock64 .#RockPro64 .#ROCPCRK3399 .#PinebookPro .#PineTab2
```

### Custom Image

Check out [the example](/example) to see how custom images can be built with 
this flake. To build the example run: `(cd example && nix flake update && nix build)`.

### Cache

Build cache is available on Cachix: [nabam-nixos-rockchip](https://app.cachix.org/cache/nabam-nixos-rockchip).
Use it to speed up builds.

#### Exported Modules
##### nixosModules.sdImageRockchip

Configures custom image build.

#### nixosModules.sdImageRockchipInstaller

Configures installer image build.

#### nixosModules.dtOverlayQuartz64ASATA

Applies device tree overlay to enable SATA port on Quartz64A.

## Supported Boards

| Board                | Attribute      | Status          |
| ---------------------|----------------| ----------------|
| Quartz64 Model A     | Quartz64A      | Tested & Works  |
| Quartz64 Model B     | Quartz64A      | Tested & Works  |
| SoQuartz Model A     | SoQuartzModelA | Tested & Works  |
| SoQuartz CM4         | SoQuartzCM4    | Tested & Works  |
| SoQuartz Blade       | SoQuartzBlade  | Tested & Works  |
| PineTab2             | PineTab2       | Tested & Works  |
| [Rock64][]           | Rock64         | Untested        |
| [RockPro64][]        | RockPro64      | Untested        |
| [ROC PC RK3399][]    | ROCPCRK3399    | Untested        |
| [Pinebook Pro][]     | PinebookPro    | Untested        |
| Orange Pi CM4        | OrangePiCM4    | Untested        |
| Radxa CM3/CM3 I/O    | RadxaCM3IO     | Untested        |
| [Radxa Rock 4][]     | RadxaRock4     | Tested & Works  |
| [Radxa Rock4 SE][]   | RadxaRock4SE   | Tested & Works  |

[Rock64]: https://wiki.nixos.org/wiki/NixOS_on_ARM/PINE64_ROCK64
[RockPro64]: https://wiki.nixos.org/wiki/NixOS_on_ARM/PINE64_ROCKPro64
[ROC PC RK3399]: https://wiki.nixos.org/wiki/NixOS_on_ARM/Libre_Computer_ROC-RK3399-PC
[Pinebook Pro]: https://wiki.nixos.org/wiki/NixOS_on_ARM/PINE64_Pinebook_Pro
[Radxa Rock 4]: https://wiki.nixos.org/wiki/NixOS_on_ARM/Radxa_ROCK_4
[Radxa Rock4 SE]: https://wiki.nixos.org/wiki/NixOS_on_ARM/Radxa_ROCK_4
