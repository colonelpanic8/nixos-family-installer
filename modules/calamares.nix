{
  lib,
  pkgs,
  ...
}: let
  targetRelease = lib.removePrefix "nixos-" (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.nixpkgs.original.ref;
  prepareTarget = pkgs.writeShellApplication {
    name = "family-prepare-target";
    runtimeInputs = [pkgs.python3 pkgs.openssh];
    text = ''
      exec python3 ${../scripts/prepare_target.py} --source ${../.} "$@"
    '';
  };
  customizeExtensions = package:
    package.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.python3];
      postPatch =
        (old.postPatch or "")
        + ''
          python3 ${../scripts/patch_calamares.py} . ${lib.getExe prepareTarget} ${lib.escapeShellArg targetRelease}
          cp -r ${../calamares/family-validate} modules/family-validate
          chmod -R u+w modules/family-validate
          substituteInPlace modules/family-validate/main.py \
            --replace-fail @helper@ ${lib.getExe prepareTarget}
          cp ${../calamares/owner.conf} config/modules/family-owner.conf
          cp ${../calamares/user.svg} branding/nixos/images/family-user.svg
        '';
    });
in {
  nixpkgs.overlays = [
    (_final: prev: {
      calamares-nixos-extensions = customizeExtensions prev.calamares-nixos-extensions;
    })
  ];
  nix.settings.experimental-features = ["nix-command" "flakes"];
  programs.partition-manager.enable = true;
  i18n.supportedLocales = ["all"];
  environment.systemPackages = [
    pkgs.calamares-nixos
    pkgs.calamares-nixos-extensions
    pkgs.glibcLocales
    pkgs.git
    prepareTarget
  ];
  environment.etc."nixos-family-installer/README.md".source = ../README.md;
  environment.etc."nixos-family-installer/AGENTS.md".source = ../AGENTS.md;
  system.build.familyCalamaresExtensions = pkgs.calamares-nixos-extensions;
}
