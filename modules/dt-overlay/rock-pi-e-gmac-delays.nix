{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  # Mainline's rx_delay = <0x11> sits at the edge of the RGMII RX timing
  # window: the gigabit port links up but corrupts received frames (CRC
  # errors), so bulk TCP into the board stalls. A sweep on a v1.2 board
  # gave no network at 0x10 and 0x28, CRC errors at 0x14 and 0x24, and a
  # clean window from 0x18 to 0x20; 0x1c is its centre. tx_delay is
  # Radxa's vendor value, which was clean at line rate.
  hardware.deviceTree.overlays = [
    {
      name = "rock-pi-e-gmac-delays";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "radxa,rockpi-e";
        };

        &gmac2io {
          tx_delay = <0x1a>;
          rx_delay = <0x1c>;
        };
      '';
    }
  ];
}
