{
  config,
  lib,
  pkgs,
  modulesPath,
  installerSource,
  ...
}: let
  prepareTarget = pkgs.writeShellApplication {
    name = "family-prepare-target";
    runtimeInputs = [pkgs.python3 pkgs.openssh];
    text = ''
      exec python3 ${../scripts/prepare_target.py} --source ${installerSource} "$@"
    '';
  };
  customizeExtensions = package:
    package.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.python3];
      postPatch =
        (old.postPatch or "")
        + ''
          python3 ${../scripts/patch_calamares.py} . ${lib.getExe prepareTarget}
          cp ${../calamares/owner.conf} config/modules/family-owner.conf
        '';
    });
in {
  imports = [(modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix")];

  nixpkgs.overlays = [
    (_final: prev: {
      calamares-nixos-extensions = customizeExtensions prev.calamares-nixos-extensions;
    })
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  environment.systemPackages = [pkgs.git pkgs.just pkgs.tailscale prepareTarget];
  services.tailscale.enable = true;
  system.build.familyCalamaresExtensions = pkgs.calamares-nixos-extensions;
  isoImage.edition = lib.mkForce "family";
  image.fileName = lib.mkForce "nixos-family-installer-${config.system.nixos.release}-x86_64-linux.iso";
}
