{
  pkgs,
  pkgs-stable,
  lib,
  fetchFromGitHub,
}:

let
  kernelConfig = with lib.kernel; {
    ARCH_ROCKCHIP = yes;
    CHARGER_RK817 = yes;
    COMMON_CLK_RK808 = yes;
    COMMON_CLK_ROCKCHIP = yes;
    DRM_ROCKCHIP = yes;
    GPIO_ROCKCHIP = yes;
    MMC_DW = yes;
    MMC_DW_ROCKCHIP = yes;
    MMC_SDHCI_OF_DWCMSHC = yes;
    MOTORCOMM_PHY = yes;
    PCIE_ROCKCHIP_DW_HOST = yes;
    PHY_ROCKCHIP_INNO_CSIDPHY = yes;
    PHY_ROCKCHIP_INNO_DSIDPHY = yes;
    PHY_ROCKCHIP_INNO_USB2 = yes;
    PHY_ROCKCHIP_NANENG_COMBO_PHY = yes;
    PINCTRL_ROCKCHIP = yes;
    PWM_ROCKCHIP = yes;
    REGULATOR_RK808 = yes;
    ROCKCHIP_DW_HDMI = yes;
    ROCKCHIP_IODOMAIN = yes;
    ROCKCHIP_IOMMU = yes;
    ROCKCHIP_MBOX = yes;
    ROCKCHIP_PHY = yes;
    ROCKCHIP_PM_DOMAINS = yes;
    ROCKCHIP_SARADC = yes;
    ROCKCHIP_THERMAL = yes;
    ROCKCHIP_VOP2 = yes;
    RTC_DRV_RK808 = yes;
    SND_SOC_RK817 = module;
    SND_SOC_ROCKCHIP_I2S_TDM = module;
    SPI_ROCKCHIP = yes;
    STMMAC_ETH = yes;
    VIDEO_HANTRO_ROCKCHIP = yes;
  };
  pinetabKernelConfig = with lib.kernel; {
    DRM_PANEL_BOE_TH101MB31UIG002_28A = yes;
  };
  pinetabKernelPatches = [
    {
      name = "Enable backlight in defconfig";
      patch = ./backlight-7.0.patch;
    }
    {
      name = "power: supply: rk817: Fix battery capacity sanity check calculation";
      patch = (
        pkgs.fetchpatch {
          name = "rk817-sanity.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/065a04c34f2bea5bde99c79b759d9a7416bfe7f2.patch";
          hash = "sha256-CU0rzv4M5dUEfCPBAxydhBRH4gY6EaAwiCvhQijP1E0=";
        }
      );
    }

    # The mmc-pwrseq change cannot be done in an overlay
    {
      name = "arm64: dts: rockchip: pinetab2: Add Bestechnic BES2600 device node";
      patch = (
        pkgs.fetchpatch {
          name = "sdmmc1-pwrseq.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/93f677cdb83fd0e197056efa228da78c0fd8a576.patch";
          hash = "sha256-bYR/QEB2mgrMW9FXp1/d9k2kWvAfmM3t4nLxcGOG/+Q=";
        }
      );
    }
    {
      name = "usb: typec: husb311: Add HUSB311 TCPI driver";
      patch = (
        pkgs.fetchpatch {
          name = "husb311.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/be6042fa9bda9cab4da6f35a40083be2c420043b.patch";
          hash = "sha256-q3LcyGnyj6EkqVGvoz6qPz2nLOb3QJNIQxKuZjJIUzU=";
        }
      );
    }
    {
      name = "usb: typec: typec-extcon: Add typec -> extcon bridge driver";
      patch = (
        pkgs.fetchpatch {
          name = "typec-extcon.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/cbb637d5f28d43b665fbdb065f4fbd41d99b26b5.patch";
          hash = "sha256-PZ9iztEHJZR1YFP/uCednNncGMqr94eEcaBvwe7gnfQ=";
        }
      );
    }
    {
      name = "usb: typec: typec-extcon: Allow to force reset on each mux change";
      patch = (
        pkgs.fetchpatch {
          name = "typec-extcon-reset.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/ba040cc6d03c480e2a0d456c8ffa70267f1e7fc9.patch";
          hash = "sha256-IDElXsEk8hCz9H8wwkpppI5WC6iz0mjLNgJZSzrnle4=";
        }
      );
    }
    {
      name = "phy: phy-rockchip-inno-usb2: Decrease delay between port init and charger detection";
      patch = (
        pkgs.fetchpatch {
          name = "inno-usb2-delay.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/f49ea8937e24d70e55487ff9b01cd4e567436954.patch";
          hash = "sha256-gUh0ECcJB++50uWTqygvPIsAWSDAAg4HTDPPsHVD0mo=";
        }
      );
    }
    {
      name = "phy: rockchip-inno-usb2: More robust charger detection extcon updates";
      patch = (
        pkgs.fetchpatch {
          name = "inno-usb2-extcon-updates.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/ba156be36961ff68f7dc324b12f32f999bf0d7aa.patch";
          hash = "sha256-rAAvLpffxcPA8d3+QX5gCVp8grlqza4CdxGOa306PmI=";
        }
      );
    }
    {
      name = "phy: rockchip: inno-usb2: Add support for RV1106/RV1103";
      patch = (
        pkgs.fetchpatch {
          name = "inno-usb2-rv11036.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/a51393386eb02d204e52c11848a9dcc854fee955.patch";
          hash = "sha256-ypRgJcgiHY94kDmZZGnJObtOWH6Sq1nKlxqL1Bg7jko=";
        }
      );
    }
    {
      name = "phy: rockchip: inno-usb2: Add RK3568 PHY tuning";
      patch = (
        pkgs.fetchpatch {
          name = "inno-usb2-rk3568-phy-tuning.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/5edf98f0ee96f79da90f5035e3aa9dac04b6ffe9.patch";
          hash = "sha256-2roU/7vh46XDnGDTDTXL1ich6q0aL0UzImBN6H4sin4=";
        }
      );
    }
    {
      name = "arm64: dts: rockchip: pinetab2: Change SD card speed to SDR50";
      patch = (
        pkgs.fetchpatch {
          name = "sd-card-speed.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/1175e9059926724ccf363397611f6fb53925ce0e.patch";
          hash = "sha256-0e8JQAJRj6hvdsjHqy9EZieVz1NypBGGpbYoZQSlF1c=";
        }
      );
    }
    {
      name = "net: bluetooth: Add quirk for broken LE buffer size v2";
      patch = (
        pkgs.fetchpatch {
          name = "bt-quirk-le-buffer.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/c3638c132135b290e40bb5303815af0d9b69803e.patch";
          hash = "sha256-qOSGSkXMvT6MaZRSgjOPiFRLs/kbrRkEcRYWEpyQdI4=";
        }
      );
    }
    {
      name = "drm/panel: boe-th101mb31ig002: Prepare the previous controller to LP-11";
      patch = (
        pkgs.fetchpatch {
          name = "boe-th101mb31ig002-lp11.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/7398078b7d9fd557b4935c313f26581d3319060e.patch";
          hash = "sha256-gA+QKzTTsd5L7eT/GRFmjlfKUIIajMgeTDWEUsX3Ayg=";
        }
      );
    }
    {
      name = "drm/panel: boe-th101mb31ig002: Longer delay on sleep out mode";
      patch = (
        pkgs.fetchpatch {
          name = "boe-th101mb31ig002-delay-on-sleep-outmode.patch";
          url = "https://codeberg.org/DanctNIX/linux-pinetab2/commit/120e2e838e3afa35d0159f8f3239e02f2b6c7822.patch";
          hash = "sha256-gl7eO3pWakfxiJbborFSAs/Jo2O+o1JvIBdNcXtRgoY=";
        }
      );
    }
  ];
  radxaRk2312BuildArgs = {
    version = "6.1.43-26-rk2312";
    modDirVersion = "6.1.43";
    src = fetchFromGitHub {
      owner = "radxa";
      repo = "kernel";
      # branch linux-6.1-stan-rkr1
      rev = "ba75427f384faf9e1246fd2aeaacffae115ba88d";
      hash = "sha256-PujHYvCuPwCMk9Yvou4Z2z51eJ6eyEeqpEs6ZYvQ3o0=";
    };
    extraMakeFlags = [
      "KCFLAGS+=-Wno-error=enum-int-mismatch"
      "KCFLAGS+=-Wno-error=calloc-transposed-args"
      "KCFLAGS+=-Wno-error=incompatible-pointer-types"
    ];
    defconfig = "rockchip_linux_defconfig";
    ignoreConfigErrors = true;
    autoModules = false;
  };
in
{
  linux_latest_rockchip_stable = pkgs-stable.linuxKernel.packagesFor (
    pkgs-stable.linuxKernel.kernels.linux_latest.override { structuredExtraConfig = kernelConfig; }
  );
  linux_latest_rockchip_unstable = pkgs.linuxKernel.packagesFor (
    pkgs.linuxKernel.kernels.linux_latest.override { structuredExtraConfig = kernelConfig; }
  );

  linux_6_1_radxa_rk2312_stable = pkgs-stable.linuxKernel.packagesFor (
    pkgs-stable.buildLinux radxaRk2312BuildArgs
  );
  linux_6_1_radxa_rk2312_unstable = pkgs.linuxKernel.packagesFor (
    pkgs.buildLinux radxaRk2312BuildArgs
  );

  linux_6_18_pinetab_stable =
    let
      version = "6.18.10-danctnix1";
    in
    pkgs-stable.linuxKernel.packagesFor (
      pkgs-stable.linuxKernel.kernels.linux_6_18.override {
        argsOverride = {
          src = pkgs.fetchFromGitea {
            domain = "codeberg.org";
            owner = "DanctNIX";
            repo = "linux-pinetab2";
            rev = "v${version}";
            hash = "sha256-AOifTyqX8x0ea6jg1GQaoiehS0H1oat3C9HK9fgMKwg=";
          };
          inherit version;
          modDirVersion = version;
        };
        kernelPatches = [
          {
            name = "Enable backlight in defconfig";
            patch = ./backlight.patch;
          }
          {
            name = "Fix rust lifetime specification";
            patch = ./patches/linux/6.18/rust-lifetime.patch;
          }
        ];
        structuredExtraConfig = kernelConfig // pinetabKernelConfig;
      }
    );

  linux_7_0_pinetab_stable = pkgs-stable.linuxKernel.packagesFor (
    pkgs-stable.linuxKernel.kernels.linux_7_0.override {
      kernelPatches = pinetabKernelPatches;
      structuredExtraConfig = kernelConfig // pinetabKernelConfig;
    }
  );

  linux_7_0_pinetab_unstable = pkgs.linuxKernel.packagesFor (
    pkgs.linuxKernel.kernels.linux_7_0.override {
      kernelPatches = pinetabKernelPatches;
      structuredExtraConfig = kernelConfig // pinetabKernelConfig;
    }
  );

  linux_6_18_orangepi5b_stable = pkgs-stable.linuxKernel.packagesFor (
    pkgs-stable.linuxKernel.kernels.linux_6_18.override {
      structuredExtraConfig = kernelConfig;
      kernelPatches = [
        {
          name = "Set the clock of the bcrm driver to 32khz as required by bcm43752.";
          patch = ./patches/linux/6.17/rk3588-0802-wireless-add-clk-property.patch;
        }
      ];
    }
  );

  linux_6_18_orangepi5b_unstable = pkgs.linuxKernel.packagesFor (
    pkgs.linuxKernel.kernels.linux_6_18.override {
      structuredExtraConfig = kernelConfig;
      kernelPatches = [
        {
          name = "Set the clock of the bcrm driver to 32khz as required by bcm43752.";
          patch = ./patches/linux/6.17/rk3588-0802-wireless-add-clk-property.patch;
        }
      ];
    }
  );
}
