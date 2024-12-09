dotfile manager is [GNU Stow](https://www.gnu.org/software/stow/)

- `.setup.sh` is the a bash script file that do some installation and initialization.

clone this repository:

```bash
git clone https://github.com/domeniczz/.dotfiles.git
```

run below command under the project root directory, to apply the config files:

```bash
stow . --adopt
```

