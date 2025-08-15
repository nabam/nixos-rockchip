{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  hardware.deviceTree.overlays = [
    {
      name = "pcie-fix";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "rockchip,rk3566";
        };

        &pcie2x1 {
          reg = <0x3 0xc0000000 0x0 0x00400000>,
                <0x0 0xfe260000 0x0 0x00010000>,
                <0x0 0xf4000000 0x0 0x00100000>;
          ranges = <0x01000000 0x0 0xf4100000 0x0 0xf4100000 0x0 0x00100000>,
                   <0x02000000 0x0 0xf4200000 0x0 0xf4200000 0x0 0x01e00000>,
                   <0x03000000 0x0 0x40000000 0x3 0x00000000 0x0 0x40000000>;
        };
      '';
    }
  ];
}
