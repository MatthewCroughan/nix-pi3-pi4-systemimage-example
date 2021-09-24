{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
  };
  outputs = { self, nixpkgs }:
  let
    mkSdImage = model: let
      eval = import (nixpkgs + "/nixos") {
        configuration = { config, pkgs, ... }: {
          imports = [
            (nixpkgs + "/nixos/modules/installer/sd-card/sd-image.nix")
          ];
          sdImage = {
            firmwareSize = 256;
            populateFirmwareCommands = ''
              ${config.system.build.installBootLoader} ${config.system.build.toplevel} -d firmware
              pwd
              ls -lh
            '';
            populateRootCommands = ''
            '';
          };
          nixpkgs.overlays = [
            (self: super: {
              makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
            })
#            (self: super: {
#              firmwareLinuxNonfree = super.firmwareLinuxNonfree.overrideAttrs (old: {
#                version = "2020-12-18";
#                src = pkgs.fetchgit {
#                  url =
#                    "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
#                  rev = "b79d2396bc630bfd9b4058459d3e82d7c3428599";
#                  sha256 = "1rb5b3fzxk5bi6kfqp76q1qszivi0v1kdz1cwj2llp5sd9ns03b5";
#                };
#                outputHash = "1p7vn2hfwca6w69jhw5zq70w44ji8mdnibm1z959aalax6ndy146";
#              });
#            })
          ];
          documentation.enable = false;
          services.avahi = {
            nssmdns = true; # Allows software to use Avahi to resolve.
            enable = true;
            publish = {
              enable = true;
              addresses = true;
              workstation = true;
            };
          };
          boot.kernelPackages = builtins.getAttr "linuxPackages_rpi${toString model}" pkgs;
          fileSystems = {
            "/" = {
              device = "/dev/disk/by-label/NIXOS_SD";
              fsType = "ext4";
            };
            "/boot" = {
              device = "/dev/disk/by-label/FIRMWARE";
              fsType = "vfat";
            };
          };
          boot.loader.grub.enable = false;
          boot.loader.raspberryPi = {
            enable = true;
            version = model;
            uboot.enable = false;
            firmwareConfig = ''
              enable_uart=1
            '';
          };
          networking.hostName = "mattpi";
          services.sshd.enable = true;
          systemd.services.wpa_supplicant.serviceConfig.Restart = "always";
          hardware = {
#            enableRedistributableFirmware = true;
            firmware = [ pkgs.wireless-regdb ];
          };
          networking = {
            useDHCP = false;
            interfaces.wlan0.useDHCP = true;
            interfaces.eth0.useDHCP = true;
#            networkmanager.wifi.backend = "iwd";
#            wireless.iwd.enable = true;
          };
          boot = {
            extraModprobeConfig = ''
              options cf680211 ieee80211_regdom="GB"
            '';
          };
#          services.octoprint = {
#            enable = true;
#            port = 5000;
#          };
#          networking.firewall.allowedTCPPorts = [ 5000 ];
          environment.systemPackages = [ pkgs.mpv ];
          users.groups.dialout.members = [ "octoprint" ];
        };
        system = "aarch64-linux";
      };
    in eval.config.system.build.sdImage;
  in {
    packages.aarch64-linux = {
      sd_image_pi3 = mkSdImage 3;
      sd_image_pi4 = mkSdImage 4;
    };
  };
}
