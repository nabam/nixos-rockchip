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
      name = "sata";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "pine64,quartz64-a", "rockchip,rk3566";
        };

        &usb_host1_xhci {
          status = "disabled";
        };
        &sata1 {
          status = "okay";
        };
      '';
    }
  ];
}
