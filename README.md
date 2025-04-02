dotfile manager is [GNU Stow](https://www.gnu.org/software/stow/)

- `.setup.sh` is a bash script file that do some installation and initialization.

clone this repository:

```bash
git clone https://github.com/domeniczz/.dotfiles.git
```

run below command under the project root directory, to apply the config files:

```bash
stow . --adopt
git restore .
```

Add $HOME/.local/scripts to PATH

My setup:

- Distro: arch linux
- Screenshot: grim + slurp + satty
- Window manager: swaywm
- Shell: zsh
- Terminal Emulator: alacritty
- Broswer: firefox / qutebroswer
- Image viewer: imv / swayimg
- Video player: mpv
- Audio: pipewire
- Launcher: bemenu
- clipboard: bemenu + wl-clipboard + cliphist
- Editor: neovim
- File manager: joshuto
- Scheduled task: crontab (cronie)
