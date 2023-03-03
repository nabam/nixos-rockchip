{ pkgs, lib }:

let
  kernelConfig = with lib.kernel; {
    SND_SOC_RK817 = yes;
    STMMAC_ETH = yes;
    MOTORCOMM_PHY = yes;
    MMC_DW = yes;
    MMC_DW_ROCKCHIP = yes;
    MMC_SDHCI_OF_DWCMSHC = yes;
    PCIE_ROCKCHIP_DW_HOST = yes;
    PHY_ROCKCHIP_NANENG_COMBO_PHY = yes;
    ROCKCHIP_DW_HDMI = yes;
    PHY_ROCKCHIP_INNO_DSIDPHY = yes;
    ROCKCHIP_VOP2 = yes;
    ARCH_ROCKCHIP = yes;
    ROCKCHIP_PHY = yes;
    PHY_ROCKCHIP_INNO_USB2 = yes;
    RTC_DRV_RK808 = yes;
    COMMON_CLK_RK808 = yes;
    MFD_RK808 = yes;
    CHARGER_RK817 = yes;
    REGULATOR_RK808 = yes;
    ROCKCHIP_PM_DOMAINS = yes;
    GPIO_ROCKCHIP = yes;
    PINCTRL_ROCKCHIP = yes;
    PWM_ROCKCHIP = yes;
    ROCKCHIP_IOMMU = yes;
    ROCKCHIP_MBOX = yes;
    ROCKCHIP_SARADC = yes;
    ROCKCHIP_THERMAL = yes;
    SPI_ROCKCHIP = yes;
    VIDEO_HANTRO_ROCKCHIP = yes;
    ROCKCHIP_IODOMAIN = yes;
    COMMON_CLK_ROCKCHIP = yes;
    PHY_ROCKCHIP_INNO_CSIDPHY = yes;
  };
in
with pkgs.linuxKernel;
{
  linux_6_1          = pkgs.linuxPackages_6_1;
  linux_6_1_rockchip = packagesFor (kernels.linux_6_1.override { structuredExtraConfig = kernelConfig; });
}

