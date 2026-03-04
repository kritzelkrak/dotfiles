# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./nvidia-611-fix.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
 
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  boot.kernelParams = [ "amd_pstate=active" ];
  boot.initrd.systemd.enable = true;

  boot.extraModprobeConfig = ''
    options nvidia_modeset vblank_sem_control=0
  '';

  networking.hostName = "<INSERT HOSTNAME HERE>"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "<INSERT TIMEZONE HERE>";

  services.xserver = { 
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['variable-refresh-rate', 'scale-monitor-framebuffer']
      '';
      extraGSettingsOverridePackages = with pkgs; [ pkgs.mutter ];
    };

    # videoDrivers = [ "nouveau" ];
    videoDrivers = [ "nvidia" ];
  };

  hardware.nvidia = {
    # enable = true;
    # package = config.boot.kernelPackages.nvidia_x11_611;
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = true;

    open = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true; 
  };
 
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # hardware.pulseaudio.enable = lib.mkForce false;
  hardware.bluetooth.enable = true;

  # Thunderbolt support.
  services.hardware.bolt.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.<INSERT USER HERE> = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  nixpkgs.config.allowUnfreePredicate = pkg: (builtins.elem (lib.getName pkg) [
    "nvidia-settings"
    "nvidia-x11"
    "blender-bin"

    "unigine-heaven"
    "unigine-superposition"
    "geekbench"
    "mprime"
  ]) || (lib.strings.hasPrefix "cuda" (lib.getName pkg));
  # boot.kernelModules = [ "nvidia-uvm" ];
  # nixpkgs.config.cudaSupport = true;

  nix.settings = {
    extra-experimental-features = [ "nix-command" "flakes" ];
  };
 
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = let 
  in with pkgs; [
    git
    neovim
    lm_sensors
    signal-desktop
    inputs.blender-bin.packages.${pkgs.system}.default
    inputs.firefox.packages.${pkgs.system}.firefox-beta-bin
  ];

  # services.corefreq.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  
  swapDevices = [{
    device = "/swapfile";
    size = 32 * 1024;
  }];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

