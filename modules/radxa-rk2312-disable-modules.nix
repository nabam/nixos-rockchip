{
  lib,
  ...
}:
{
  boot.initrd.availableKernelModules = {
    "ata_piix" = lib.mkForce false;

    "sata_inic162x" = lib.mkForce false;
    "sata_nv" = lib.mkForce false;
    "sata_promise" = lib.mkForce false;
    "sata_qstor" = lib.mkForce false;
    "sata_sil" = lib.mkForce false;
    "sata_sil24" = lib.mkForce false;
    "sata_sis" = lib.mkForce false;
    "sata_svw" = lib.mkForce false;
    "sata_sx4" = lib.mkForce false;
    "sata_uli" = lib.mkForce false;
    "sata_via" = lib.mkForce false;
    "sata_vsc" = lib.mkForce false;

    "pata_ali" = lib.mkForce false;
    "pata_amd" = lib.mkForce false;
    "pata_artop" = lib.mkForce false;
    "pata_atiixp" = lib.mkForce false;
    "pata_efar" = lib.mkForce false;
    "pata_hpt366" = lib.mkForce false;
    "pata_hpt37x" = lib.mkForce false;
    "pata_hpt3x2n" = lib.mkForce false;
    "pata_hpt3x3" = lib.mkForce false;
    "pata_it8213" = lib.mkForce false;
    "pata_it821x" = lib.mkForce false;
    "pata_jmicron" = lib.mkForce false;
    "pata_marvell" = lib.mkForce false;
    "pata_mpiix" = lib.mkForce false;
    "pata_netcell" = lib.mkForce false;
    "pata_ns87410" = lib.mkForce false;
    "pata_oldpiix" = lib.mkForce false;
    "pata_pcmcia" = lib.mkForce false;
    "pata_pdc2027x" = lib.mkForce false;
    "pata_rz1000" = lib.mkForce false;
    "pata_serverworks" = lib.mkForce false;
    "pata_sil680" = lib.mkForce false;
    "pata_sis" = lib.mkForce false;
    "pata_sl82c105" = lib.mkForce false;
    "pata_triflex" = lib.mkForce false;
    "pata_via" = lib.mkForce false;
    "pata_qdi" = lib.mkForce false;
    "pata_winbond" = lib.mkForce false;

    "3w-9xxx" = lib.mkForce false;
    "3w-xxxx" = lib.mkForce false;
    "aic79xx" = lib.mkForce false;
    "aic7xxx" = lib.mkForce false;
    "arcmsr" = lib.mkForce false;
    "hpsa" = lib.mkForce false;

    "sdhci_pci" = lib.mkForce false;

    "ohci1394" = lib.mkForce false;
    "sbp2" = lib.mkForce false;

    "virtio_net" = lib.mkForce false;
    "virtio_pci" = lib.mkForce false;
    "virtio_mmio" = lib.mkForce false;
    "virtio_blk" = lib.mkForce false;
    "virtio_scsi" = lib.mkForce false;
    "virtio_balloon" = lib.mkForce false;
    "virtio_console" = lib.mkForce false;

    "mptspi" = lib.mkForce false;
    "vmxnet3" = lib.mkForce false;

    "sun4i-drm" = lib.mkForce false;
    "sun8i-mixer" = lib.mkForce false;

    "pwm-sun4i" = lib.mkForce false;

    "vc4" = lib.mkForce false;

    "pcie-brcmstb" = lib.mkForce false;

    "rockchipdrm" = lib.mkForce false;
    "rockchip-rga" = lib.mkForce false;
    "pcie-rockchip-host" = lib.mkForce false;

    "axp20x-ac-power" = lib.mkForce false;
    "axp20x-battery" = lib.mkForce false;
    "pinctrl-axp209" = lib.mkForce false;
    "mp8859" = lib.mkForce false;

    "xhci-pci-renesas" = lib.mkForce false;

    "reset-raspberrypi" = lib.mkForce false;

    "analogix-dp" = lib.mkForce false;
    "analogix-anx6345" = lib.mkForce false;

    "uhci_hcd" = lib.mkForce false;
    "ohci_pci" = lib.mkForce false;

    "hid_lenovo" = lib.mkForce false;
    "hid_apple" = lib.mkForce false;
    "hid_roccat" = lib.mkForce false;
    "hid_logitech_hidpp" = lib.mkForce false;
    "hid_logitech_dj" = lib.mkForce false;
    "hid_microsoft" = lib.mkForce false;
    "hid_cherry" = lib.mkForce false;
    "hid_corsair" = lib.mkForce false;

    "tpm-crb" = lib.mkForce false;
    "tpm-tis" = lib.mkForce false;
  };
}
