# Lightcord Linux installer

The installer for Lightcord on Linux! It can install, update and uninstall Lightcord!

This installer has been moved to it's own repo in order to make maintenance easier.

## Installation

### Arch Linux (or derivatives)

You need to install the `base-devel` and `git` packages first

[Latest git version](https://aur.archlinux.org/packages/lightcord-git/)

`git clone https://aur.archlinux.org/lightcord-git.git && cd lightcord-git && makepkg -si`

[Precompiled binaries](https://aur.archlinux.org/packages/lightcord-bin/)

`git clone https://aur.archlinux.org/lightcord-bin.git && cd lightcord-bin && makepkg -si`

*AUR helpers such as `yay` and `pacaur` can also be used*

### Other Linux distributions

Run the installer using this command:
`bash -c "$(curl -s https://raw.githubusercontent.com/Lightcord/lc-installer-linux/master/lightcordctl)"`

Legacy installer:
`sh -c "$(curl -s https://raw.githubusercontent.com/Lightcord/lc-installer-linux/master/LULI.sh)"`

The installer will greet you with an interactive menu

### Remarks

* Do not use this script if your Distro has a package for Lightcord

## Contributing

1. Fork the repo
2. Clone your fork
3. Make changes
4. Create a pull request