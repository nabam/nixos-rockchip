{ pkgs, lib }:

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
    SND_SOC_RK817 = yes;
    SND_SOC_ROCKCHIP = yes;
    SND_SOC_ROCKCHIP_I2S_TDM = yes;
    SPI_ROCKCHIP = yes;
    STMMAC_ETH = yes;
    VIDEO_HANTRO_ROCKCHIP = yes;
  };
  pinetabKernelConfig = with lib.kernel; {
    BES2600 = module;
    BES2600_5GHZ_SUPPORT = yes;
    BES2600_DEBUGFS = yes;

    DRM_PANEL_BOE_TH101MB31UIG002_28A = yes;
  };
in with pkgs.linuxKernel; {
  linux_6_6 = pkgs.linuxPackages_6_6;
  linux_6_6_rockchip = packagesFor
    (kernels.linux_6_6.override {
      structuredExtraConfig = kernelConfig;
      kernelPatches = [{
        name = "Fix nvme on rk3566";
        patch = ./fix-nvme.patch;
      }];
    });

  linux_6_12 = pkgs.linuxPackages_6_12;
  linux_6_12_rockchip = packagesFor
    (kernels.linux_6_12.override {
      structuredExtraConfig = kernelConfig;
      kernelPatches = [{
        name = "Fix nvme on rk3566";
        patch = ./fix-nvme.patch;
      }];
    });

  linux_6_12_pinetab = packagesFor (kernels.linux_6_12.override {
    argsOverride = {
      src = pkgs.fetchFromGitHub {
        owner = "dreemurrs-embedded";
        repo = "linux-pinetab2";
        rev = "c20c98ab973a6042508dea01c152d7e4a486adea";
        sha256 = "nOhz8IVhsc3MNdSBgdrAANWUzfYodiR6QIo5WfKmrMM=";
      };
      version = "6.12.9-danctnix2";
      modDirVersion = "6.12.9-danctnix2";
    };
    kernelPatches = [{
      name = "Enable backlight in defconfig";
      patch = ./backlight.patch;
    }];
    structuredExtraConfig = kernelConfig // pinetabKernelConfig;
  });
}

