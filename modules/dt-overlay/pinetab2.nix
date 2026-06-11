{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  # This is all changes *except*
  # "arm64: dts: rockchip: pinetab2: Add Bestechnic BES2600 device node"
  # and
  # "arm64: dts: rockchip: pinetab2: Change SD card speed to SDR50"
  # because those remove items, which cannot be done in an overlay.
  hardware.deviceTree.overlays = [
    {
      name = "pinetab2-v2.0";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        #include <dt-bindings/pinctrl/rockchip.h>
        #include <dt-bindings/gpio/gpio.h>
        #include <dt-bindings/interrupt-controller/irq.h>
        #include <dt-bindings/usb/pd.h>

        /* I don't fully understand why this needs to be split up
           into two nodes and one should use the '&{/}' syntax, but
           by trial and error this is the variation that works
           (typec-extcon is created and bes2600 is correctly linked).
           To review.
        */
        / {
          compatible = "pine64,pinetab2-v2.0";

          aliases {
            ethernet0 = &bes2600;
          };
        };

        &{/} {
          typec_extcon_bridge: typec-extcon {
            compatible = "linux,typec-extcon-bridge";
            usb-role-switch;
            mode-switch;
            orientation-switch;
          };

          sdio_pwrkey: sdio-pwrkey {
            compatible = "mmc-pwrseq-simple";
            clocks = <&rk817 1>;
            clock-names = "ext_clock";
            pinctrl-names = "default";
            pinctrl-0 = <&wifi_pwrkey>;
            reset-gpios = <&gpio3 RK_PD3 GPIO_ACTIVE_HIGH>;
            post-power-on-delay-ms = <500>;
          };

          sdio_pwrseq: sdio-pwrseq {
            compatible = "mmc-pwrseq-simple";
            clocks = <&rk817 1>;
            clock-names = "ext_clock";
            pinctrl-names = "default";
            pinctrl-0 = <&wifi_reset>;
            reset-gpios = <&gpio3 RK_PD2 GPIO_ACTIVE_LOW>;
            post-power-on-delay-ms = <200>;
          };

          vcc_wl: vcc_wl {
            compatible = "regulator-fixed";
            pinctrl-names = "default";
            pinctrl-0 = <&wifi_pwren>;
            regulator-name = "vcc_wl";
            regulator-min-microvolt = <3300000>;
            regulator-max-microvolt = <3300000>;
            vin-supply = <&vcc3v3_sys>;

            // note enable-active-high is not valid for v0.1, only v2.0
            enable-active-high;
            gpio = <&gpio0 RK_PA0 GPIO_ACTIVE_HIGH>;

            regulator-state-mem {
              regulator-off-in-suspend;
            };
          };
        };

        &sdmmc1 {
          vmmc-supply = <&vcc_wl>;
          #address-cells = <1>;
          #size-cells = <0>;
          mmc-pwrseq = <&sdio_pwrseq &sdio_pwrkey>;
          bes2600: bes2600@0 {
            compatible = "bestechnic,bes2600-sdio";
            reg = <0>;
            wakeup-gpios = <&gpio0 RK_PB7 GPIO_ACTIVE_LOW>;
            host-wakeup-gpios = <&gpio0 RK_PC4 GPIO_ACTIVE_HIGH>;
          };
        };

        &rk817 {
          regulators {
            vdd_gpu_npu: DCDC_REG2 {
              regulator-always-on;
              regulator-boot-on;
            };
          };
        };

        &i2c0 {
          usbc0: usb-typec@4e {
            compatible = "hynetek,husb311", "richtek,rt1711h";
            reg = <0x4e>;
            interrupt-parent = <&gpio0>;
            interrupts = <RK_PC5 IRQ_TYPE_LEVEL_LOW>;
            pinctrl-names = "default";
            pinctrl-0 = <&usbcc_int_l>;
            vbus-supply = <&vbus>;

            connector {
              compatible = "usb-c-connector";
              label = "USB-C";
              data-role = "dual";
              power-role = "dual";
              try-power-role = "sink";
              op-sink-microwatt = <2500000>;
              sink-pdos = <PDO_FIXED(5000, 3000, PDO_FIXED_USB_COMM)>;
              source-pdos = <PDO_FIXED(5000, 500, PDO_FIXED_USB_COMM)>;
              mode-switch = <&typec_extcon_bridge>;
              orientation-switch = <&typec_extcon_bridge>;
              usb-role-switch = <&typec_extcon_bridge>;

              port {
                typec_hs_usb_host0_xhci: endpoint {
                  remote-endpoint = <&usb_host0_xhci_typec_hs>;
                };
              };
            };
          };
        };

        &pinctrl {
          bt {
            bt_reg_on_h: bt-reg-on-h {
              rockchip,pins = <0 RK_PC1 RK_FUNC_GPIO &pcfg_pull_none>;
            };

            bt_wake_host_h: bt-wake-host-h {
              rockchip,pins = <0 RK_PB5 RK_FUNC_GPIO &pcfg_pull_down>;
            };

            host_wake_bt_h: host-wake-bt-h {
              rockchip,pins = <0 RK_PB6 RK_FUNC_GPIO &pcfg_pull_none>;
            };
          };

          usb {
            usbcc_int_l: usbcc-int-l {
              rockchip,pins = <0 RK_PC5 RK_FUNC_GPIO &pcfg_pull_up>;
            };
          };

          wifi {
            wifi_pwrkey: wifi-pwrkey {
              rockchip,pins = <3 RK_PD3 RK_FUNC_GPIO &pcfg_pull_none>;
            };

            wifi_pwren: wifi-pwren {
              rockchip,pins = <0 RK_PA0 RK_FUNC_GPIO &pcfg_pull_none>;
            };
  
            wifi_reg_on_h: wifi-reg-on-h {
              rockchip,pins = <0 RK_PC0 RK_FUNC_GPIO &pcfg_pull_none>;
            };
  
            wifi_reset: wifi-reset {
              rockchip,pins = <3 RK_PD2 RK_FUNC_GPIO &pcfg_pull_none>;
            };
          };
        };

        &uart1 {
          pinctrl-0 = <&uart1m0_ctsn>, <&uart1m0_rtsn>, <&uart1m0_xfer>;
          pinctrl-names = "default";
          uart-has-rtscts;
          status = "okay";

          bluetooth {
            compatible = "bestechnic,bes2600-btuart";
            interrupts-extended = <&gpio0 RK_PB5 IRQ_TYPE_LEVEL_HIGH>;
            interrupt-names = "wakeup";
            wakeup-source;

            pinctrl-names = "default";
            pinctrl-0 = <&bt_reg_on_h>, <&bt_wake_host_h>, <&host_wake_bt_h>;

            power-gpios = <&gpio0 RK_PC1 GPIO_ACTIVE_HIGH>;
            wakeup-gpios = <&gpio0 RK_PB6 GPIO_ACTIVE_HIGH>;
            host-wakeup-gpios = <&gpio0 RK_PB5 GPIO_ACTIVE_HIGH>;
          };
        };

        /* OTG port controller */
        &usb_host0_xhci {
          extcon = <&typec_extcon_bridge>;

          port {
            usb_host0_xhci_typec_hs: endpoint {
              remote-endpoint = <&typec_hs_usb_host0_xhci>;
            };
          };
        };

        &usb2phy0 {
          extcon = <&typec_extcon_bridge>;
        };
      '';
    }
  ];

  hardware.deviceTree.dtbSource =
    let
      patchPineTabDtb = pkgs.writers.writePython3 "patch-pinetab2-dtb.py" {
        libraries = [ pkgs.python3Packages.libfdt ];
      } ''
        import sys
        import libfdt

        with open(sys.argv[1], "rb") as f:
            fdt = libfdt.Fdt(bytearray(f.read()))

        fdt.resize(fdt.totalsize() + 256)

        # sdmmc0: cap SD card UHS at SDR50
        # like in 'arm64: dts: rockchip: pinetab2: Change SD card speed to SDR50'
        sd = fdt.path_offset("/mmc@fe2b0000")
        fdt.delprop(sd, "sd-uhs-sdr104")
        fdt.setprop(sd, "sd-uhs-sdr50", b"")

        # sdmmc1: drop the static regulator supply from SDIO (wifi)
        # like in 'arm64: dts: rockchip: pinetab2: Add Bestechnic BES2600 device node'
        sdio = fdt.path_offset("/mmc@fe2c0000")
        fdt.delprop(sdio, "vmmc-supply")

        fdt.pack()

        with open(sys.argv[1], "wb") as f:
            f.write(fdt.as_bytearray())
      '';
    in
      pkgs.runCommand "pinetab2-patch-dtbs" { } ''
        cp -r ${config.boot.kernelPackages.kernel}/dtbs $out
        chmod -R u+w $out
        ${patchPineTabDtb} $out/rockchip/rk3566-pinetab2-v2.0.dtb
      '';

}
