# Project scope

This repository builds a Calamares NixOS installer. `dotfiles/` is a pinned
Git submodule, consumed as source files, never by evaluating its workstation
flake. The target's account comes from Calamares; owner (`ivan` / `other`)
is independent of the login name.

## Structure

- `modules/iso.nix`: graphical media and package override.
- `calamares/owner.conf`: owner selection page.
- `scripts/patch_calamares.py`: narrow, checked patch against pinned upstream.
- `scripts/prepare_target.py`: copy release source, preserve generated hardware
  and boot configuration, create permanent host identity and public request.
- `machines/<hostname>/`: reviewed registrations used by managed updates.
- `dotfiles/nixos/profiles/installer-user.nix`: safe shared user preferences.

## Invariants

- Never import `dotfiles/nixos/configuration.nix` into a family installation.
- Owner selection does not grant secret access. Do not import personal GPG,
  Git-sync, password-store, Syncthing or agent credentials implicitly.
- Keep Calamares' partition/encryption, user password, and bootloader handling.
- Private host keys stay on the target. Enrollment requests contain public data.
- Do not enable automatic updates until the host exists on the published
  `family-stable` ref. Never reboot unattended by default.
- The dotfiles source checkout at `/srv/dotfiles` has its own AGENTS.md and must
  not use Git worktrees. Make upstream changes there and advance this gitlink;
  do not develop inside the vendored submodule checkout.

## Development

Use Nix 2.27+ (self-submodule support), `git submodule update --init --recursive`,
and `direnv allow`. Run `direnv exec . just check`, then `nix flake check` to
build checks. `just build` builds the ISO; `just vm` boots it in a disposable VM.
An ISO build is not proof that installation succeeds: verify installation,
reboot, primary account and exclusions in the VM before shipping media.

Only format this repository's files, not the dotfiles submodule wholesale.
