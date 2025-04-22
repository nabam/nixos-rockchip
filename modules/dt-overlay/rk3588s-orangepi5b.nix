{ ... }: {
  hardware.deviceTree = {
    enable = true;
    filter = "rk3588s-orangepi-5b.dtb";
    overlays = [{
      name = "orangepi-5b";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "xunlong,orangepi-5b", "rockchip,rk3588s";
          aliases {
            mmc0 = <&sdmmc>;
            mmc1 = <&sdhci>;
          };

          vcc3v3_pcie20: regulator-vcc3v3-pcie20 {
            compatible = "regulator-fixed";
            enable-active-high;
            gpios = <0xb7 21 0x0>;
            regulator-name = "vcc3v3_pcie20";
            regulator-boot-on;
            regulator-min-microvolt = <1800000>;
            regulator-max-microvolt = <1800000>;
            startup-delay-us = <50000>;
            vin-supply = <&vcc5v0_sys>;
          };
        };

        &sfc {
          status = "disabled";
        };

        &pcie2x1l2 {
          status = "okay";
          vpcie3v3-supply = <&vcc3v3_pcie20>;
          reset-gpios = <0x84 25 0x0>;
          pcie@0,0 {
          reg = <0x400000 0 0 0 0>;
            #address-cells = <3>;
            #size-cells = <2>;
            ranges;
            device_type = "pci";
            bus-range = <0x40 0x4f>;

            wifi: wifi@0,0 {
              compatible = "pci14e4,449d";
              reg = <0x410000 0 0 0 0>;
              clocks = <&hym8563>;
              clock-names = "32k";
            };
          };
        };

        &gpio0 {
          wifi_en_gpio {
            gpio-hog;
            gpios = <24 0>;
            output-high;
            line-name = "wifi-power-enable";
          };
        };
      '';
    }];
  };
}

