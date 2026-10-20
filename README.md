# Moved to dotfiles

The family installer now lives in
[`colonelpanic8/dotfiles/nixos/family-installer`](https://github.com/colonelpanic8/dotfiles/tree/master/nixos/family-installer),
alongside the existing rescue ISO and persistent USB configuration.

Read the [current operating guide](https://github.com/colonelpanic8/dotfiles/blob/master/nixos/family-installer/README.md)
and [agent instructions](https://github.com/colonelpanic8/dotfiles/blob/master/nixos/family-installer/AGENTS.md).
Those are the instructions to use if you followed a link in Alex's setup email.
An assisting agent should read both before taking any action.

For a new installation, use dotfiles' conservative `family-stable` branch:

```sh
git clone https://github.com/colonelpanic8/dotfiles.git
cd dotfiles
git switch family-stable
cd nixos/family-installer
nix develop --command just check
nix flake check
nix develop --command just build
```

Build on x86_64 Linux with Nix and flakes. If your computer cannot build the
image, ask Ivan for a prebuilt ISO and its checksum. There is no ready-made ISO
download in this repository.

**Writing the installer wipes everything on the selected USB stick.** Back up
its files and confirm the exact device by model and capacity before writing.
Installing onto the computer is a separate destructive step. Coordinate with
Ivan and back up the computer before starting that installation.

This repository preserves the earlier implementation and release history.
Do not develop or register new machines here. The dotfiles installer is
self-contained, needs no dotfiles submodule, and retains its own stable Nixpkgs
and Home Manager lockfile. Existing USBs retain their original code until rebuilt.
