{
  pkgs,
  pkgs-stable,
  lib,
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
    BES2600 = module;
    BES2600_5GHZ_SUPPORT = yes;
    BES2600_DEBUGFS = yes;

    DRM_PANEL_BOE_TH101MB31UIG002_28A = yes;
  };
in
with pkgs.linuxKernel;
{
  linux_stable_latest = pkgs-stable.linuxPackages_latest;
  linux_unstable_latest = pkgs.linuxPackages_latest;

  linux_stable_rockchip = pkgs-stable.linuxKernel.packagesFor (
    pkgs-stable.linuxKernel.kernels.linux_latest.override { structuredExtraConfig = kernelConfig; }
  );
  linux_unstable_rockchip = pkgs.linuxKernel.packagesFor (
    pkgs.linuxKernel.kernels.linux_latest.override { structuredExtraConfig = kernelConfig; }
  );

  linux_6_12_rockchip = pkgs-stable.linuxKernel.packagesFor (
    pkgs-stable.linuxKernel.kernels.linux_6_12.override { structuredExtraConfig = kernelConfig; }
  );

  linux_6_12 = pkgs-stable.linuxPackages_6_12;
  linux_6_12_rockchip = pkgs-stable.linuxKernel.packagesFor (
    pkgs-stable.linuxKernel.kernels.linux_6_12.override { structuredExtraConfig = kernelConfig; }
  );

  linux_6_17 = pkgs.linuxPackages_6_17;
  linux_6_17_rockchip = packagesFor (
    kernels.linux_6_17.override { structuredExtraConfig = kernelConfig; }
  );

  linux_6_17_pinetab =
    let
      version = "6.17.8-danctnix1";
    in
    pkgs-stable.linuxKernel.packagesFor (
      pkgs-stable.linuxKernel.kernels.linux_6_17.override {
        argsOverride = {
          src = pkgs.fetchFromGitea {
            domain = "codeberg.org";
            owner = "DanctNIX";
            repo = "linux-pinetab2";
            rev = "v${version}";
            hash = "sha256-32u5vmwyY/p92ecD4ve0lnYIm1o2Pabj65+dIt1EQI4=";
          };
          inherit version;
          modDirVersion = version;
        };
        kernelPatches = [
          {
            name = "Enable backlight in defconfig";
            patch = ./backlight.patch;
          }
        ];
        structuredExtraConfig = kernelConfig // pinetabKernelConfig;
      }
    );

  linux_6_17_orangepi5b = pkgs-stable.linuxKernel.packagesFor (
    pkgs-stable.linuxKernel.kernels.linux_6_17.override {
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
