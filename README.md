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

Execute `sh -c "$(curl -s https://raw.githubusercontent.com/Lightcord/lc-installer-linux/master/LULI.sh)"`

*Try out the rewrite! (not feature complete yet)* `bash -c "$(curl -s https://raw.githubusercontent.com/Lightcord/lc-installer-linux/master/rewrite.sh)"`

The installer will present you with a interactive menu

### Remarks

* If you use this script to install Lightcord, use it to uninstall again. This script is smart enough to detect if you used your package manager to install Lightcord.
* If you use Bedrock Linux make sure that the installer's and Lightcord's requirements are statisfied in the stratus you're installing Lightcord in!

## Contributing

1. Fork the repo
2. Clone your fork
3. Make changes
4. Create a pull request