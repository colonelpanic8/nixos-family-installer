# Agent instructions

Read [README.md](README.md) before assisting with installation, remote support,
registration, updates, or recovery. It is the operating guide for both the
person at the computer and an assisting agent. Start with its
[agent instructions](README.md#instructions-for-an-assisting-agent), then use
the section for the current stage. Establish which computer and environment
you are controlling before running commands.

On combined rescue media, this guide and README are installed under
`/etc/nixos-family-installer`. On a family target, the source copy is under
`/srv/nixos-family-installer`. Follow local machine instructions as well.

## Project scope

This repository builds a Calamares NixOS installer. `dotfiles/` is a pinned
Git submodule, consumed as source files, never by evaluating its workstation
flake. The target's account comes from Calamares; owner (`ivan` / `other`)
is independent of the login name.

## Structure

- `modules/iso.nix`: standalone graphical media.
- `modules/calamares.nix`: reusable installer, package override, and support guide.
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
