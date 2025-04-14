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
    (kernels.linux_6_6.override { structuredExtraConfig = kernelConfig; });

  linux_6_12 = pkgs.linuxPackages_6_12;
  linux_6_12_rockchip = packagesFor
    (kernels.linux_6_12.override { structuredExtraConfig = kernelConfig; });

  linux_6_13 = pkgs.linuxPackages_6_13;
  linux_6_13_rockchip = packagesFor
    (kernels.linux_6_13.override { structuredExtraConfig = kernelConfig; });

  linux_6_13_pinetab = packagesFor (kernels.linux_6_13.override {
    argsOverride = {
      src = pkgs.fetchFromGitHub {
        owner = "dreemurrs-embedded";
        repo = "linux-pinetab2";
        rev = "99c89e3980f92dd8f9e0a6a8efe95b50f6d9fb9f";
        sha256 = "i3kgjIpWUMhKYfMP/NIEFIiLb8DOMd6+Rqz9FCvfYKk=";
      };
      version = "6.13.6-danctnix1";
      modDirVersion = "6.13.6-danctnix1";
    };
    kernelPatches = [{
      name = "Enable backlight in defconfig";
      patch = ./backlight.patch;
    }];
    structuredExtraConfig = kernelConfig // pinetabKernelConfig;
  });

  linux_6_13_orangepi5b = packagesFor (kernels.linux_6_13.override {
    structuredExtraConfig = kernelConfig;
    kernelPatches = [
      {
        name = "Set the clock of the bcrm driver to 32khz as required by bcm43752.";
        patch = ./patches/linux/6.13/rk3588-0802-wireless-add-clk-property.patch;
      }
    ];
  });
}

