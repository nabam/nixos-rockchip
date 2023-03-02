{ config, pkgs, lib, ... }:
let 
  sensitive = import ./sensitive.nix;
in
{

  system.stateVersion = "22.11";

  networking.hostName = "quartz64";
  zramSwap.enable = true;

  boot.initrd.availableKernelModules = lib.mkForce [ 
    "mmc_block"
  ];

  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    networks = {
      ${sensitive.wifi.ssid} = {
        pskRaw = sensitive.wifi.pskRaw;
      };
    };
  };

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.console-user = {
    isNormalUser = true;
    home = "/home/console-user";
    description = "Virtual console user";
    extraGroups = [ "wheel" ];
  };

  users.users.ssh-user = {
    isNormalUser = true;
    home = "/home/ssh-user";
    description = "SSH user";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ 
      sensitive.ssh.authorizedKeys
    ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Automatically log in at the virtual consoles.
  services.getty.autologinUser = "console-user";
}

