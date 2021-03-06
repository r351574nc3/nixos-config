# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  user = "leo";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Use the GRUB 2 boot loader.
  boot.loader = {
    grub = {
      enable = true;
      version = 2;
      # boot.loader.grub.efiSupport = true;
      # boot.loader.grub.efiInstallAsRemovable = true;
      # boot.loader.efi.efiSysMountPoint = "/boot/efi";
      # Define on which hard drive you want to install Grub.
      device = "/dev/vda"; # or "nodev" for efi only
    };
  };

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
 
  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" ];
  };

  environment.shells = [
    pkgs.bashInteractive
    pkgs.zsh
    pkgs.fish
  ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
      emacs
      curl
      wget
      fish
      openssl
      k3s
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  #   firefox
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.k3s = {
    enable = true;
    role = "server";
    #disableAgent = true;
    docker = lib.mkForce false;
    extraFlags = toString [
      "--tls-san"
      "192.168.222.29"
      "--no-deploy"
      "traefik"
      "--container-runtime-endpoint"
      "unix:///run/containerd/containerd.sock"
    ];
  };

  virtualisation.containerd = {
    enable = true;
    settings =
      let
        fullCNIPlugins = pkgs.buildEnv {
          name = "full-cni";
          paths = with pkgs;[
            cni-plugins
            cni-plugin-flannel
          ];
        };
      in {
        version = 2;
        plugins."io.containerd.grpc.v1.cri".cni = {
          bin_dir = "${fullCNIPlugins}/bin";
          conf_dir = "/var/lib/rancher/k3s/agent/etc/cni/net.d/";
        };
      };
  };

  #systemd.services.k3s = {
  #  #wants = ["containerd.service"];
  #  #after = ["containerd.service"];
  #  # Install
  #  wantedBy = [ "multi-user.target" ];
  #};

  # systemd.services.k3s-agent = {
     # Unit
  #    description = "Lightweight Kubernetes";
  #    documentation = [ "https://k3s.io" ];
  #    wants = [ "network-online.target" ];
  #    # Install
  #     wantedBy = [ "multi-user.target" ];
  #     # Service
  #     serviceConfig = {
  #       Type = "exec";
  #       KillMode = "process";
  #       Delgate = "yes";
  #       LimitNOFILE = "infinity";
  #       LimitNPROC = "infinity";
  #       LimitCORE = "infinity";
  #       TasksMax = "infinity";
  #       TimeoutStartSec = "0";
  #       Restart = "always";
  #       RestartSec = "5s";
  #       ExecStartPre = "${pkgs.kmod}/bin/modprobe -a br_netfilter overlay";
  #       ExecStart = "${pkgs.k3s}/bin/k3s agent --server https://10.1.2.20:6443 --token-file /var/keys/k3s_token";         
  #     };
  #  };
  
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.

  networking.firewall.allowedTCPPorts = [ 6443 ];
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

