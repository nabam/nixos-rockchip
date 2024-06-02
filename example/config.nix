{ config, pkgs, lib, ... }: {
  system.stateVersion = "24.05";

  networking.hostName = "quartz64";
  zramSwap.enable = true;

  networking.wireless = {
    enable = true;
    userControlled.enable = true;
    #    networks = {
    #      XXX = {
    #        psk = "XXX";
    #      };
    #    };
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
      #      "XXX"
    ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Automatically log in at the virtual consoles.
  services.getty.autologinUser = "console-user";

  nixpkgs.config.allowUnfree = true;
}

