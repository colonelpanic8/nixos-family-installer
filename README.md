# NixOS family installer

A graphical NixOS installer with a pinned
[dotfiles](https://github.com/colonelpanic8/dotfiles) Git submodule. Calamares
handles disk selection, partitioning, encryption, locale, desktop, passwords,
and installation progress. One extra page chooses **Ivan** or **Another person**;
the normal account page chooses the primary user's actual login name.

The installer retains Calamares' generated hardware and bootloader configuration
and installs a local flake using the shared user profile from dotfiles. It does
not evaluate the workstation flake, fetch its private Railbird input, or require
the Taffybar checkout at `/srv/dotfiles`.

## What each owner gets

Both choices get flakes, Zsh, tmux, Zellij, the shared multiplexer aliases, and
Git. **Ivan** also gets his Git name and email. **Another person** gets no
inherited Git identity. The initial profile is deliberately a small reusable
subset; the full workstation dotfiles are not symlinked into the new account.

Neither choice imports Ivan's GPG key/passphrase, password store, Git-sync
repositories, Syncthing folders, personal credentials, or other users' accounts.
Selecting Ivan is a preference choice, not authentication or secret approval.

## Build

Nix 2.27+ is required for `inputs.self.submodules`.

```sh
git clone --recurse-submodules <installer-repository>
cd nixos-family-installer
direnv allow
direnv exec . just check
nix flake check
direnv exec . just build
```

The ISO is under `result/iso/`. `direnv exec . just vm` opens it with a new
disposable VM disk; that command never selects or writes a physical disk.
For remote Git flake URLs use `git+https://...?...&submodules=1`, because GitHub
archive fetches do not include submodules.

## Installation

1. Boot the ISO and connect through the normal desktop network applet.
2. Open the graphical installer. Select the owner, then create the primary
   account. The login name can differ from `imalison` even when selecting Ivan.
3. Choose the desktop, disks and encryption through the normal installer pages.
4. Complete installation and reboot.

The target contains:

- `/srv/nixos-family-installer`: the exact release source plus the new
  `machines/<hostname>/` definition, without Git metadata.
- `/etc/nixos`: a link to that flake, so ordinary rebuilds use it automatically.
  The original generated files remain under `/etc/nixos.calamares`.
- `/etc/ssh/ssh_host_ed25519_key`: a freshly generated permanent host identity.
  Retrying preparation preserves this key.
- `/var/lib/nixos-family-installer/enrollment.json`: a public registration request.

The machine definition preserves the generated boot, disk, locale and account
settings. Personal preference files come from immutable release source, so a
separate Git pull cannot silently change them.

## Registration and conservative updates

The first installation works without secret approval or a merged machine PR.
Automatic updates remain disabled until registration, because the published
release cannot address a hostname that has not been added yet.

On your trusted workstation, review the public request and copy
`machines/<hostname>/` from the installed system into this repository. Verify
the host-key fingerprint through the support session. Add only explicitly
approved recipients to any secret policy; never add the new key to dotfiles'
broad `hostKeys`, `sshClientKeys` or `agenixKeys` groups. The default request
asks for no secrets.

Once the definition has been reviewed, tested and published on `family-stable`,
enable `familyInstaller.updates.enable` in that machine's module and activate
that release through the approved deployment procedure. Updates honor the
release lockfile, run daily with jitter, retain boot entries, and do not reboot
automatically. `familyInstaller.updates.source` can point to another Git remote
or release ref. The default URL is the intended repository location, not an
assertion that the repository has already been published.

Tailscale is available on the live media for support. Automatic enrollment,
policy management, secret re-encryption and authenticated PR creation are not
performed by the installer. They belong to a separately authorized trusted
workstation step; no reusable enrollment key or GitHub token is embedded in
the ISO.

## Updating dotfiles

Make and verify changes in the primary `/srv/dotfiles` checkout, publish them,
then advance `dotfiles/` here to that commit. Updating the gitlink is the only
dotfiles version pin; there is no second flake input tracking another revision.
Run the profile checks and VM installation before promoting `family-stable`.
Other flake dependencies are independently pinned in `flake.lock` on NixOS and
Home Manager 26.05.

The repository's original code is MIT licensed. Bundled NixOS, Calamares and
other dependencies retain their respective upstream licenses.
