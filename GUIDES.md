# Connect to WIFI on Arch Linux

> https://wiki.archlinux.org/title/NetworkManager

1. `nmcli device wifi list` to list nearby WIFIs.
2. `nmcli device wifi connect SSID_or_BSSID password PWD` to connect to a WIFI.
3. `nmcli connection show` to show all saved connections.
4. `nmcli radio wifi off` to turn off WIFI.
5. `nmcli connection delete CONNECTION_NAME`


# Setup bluetooth on Arch Linux

> https://wiki.archlinux.org/title/Bluetooth_headset

Ensure `bluez`, `bluez-libs`, `bluez-utils`, `pulseaudio-alsa`, `pulseaudio-bluetooth` are installed.

If installing `pulseaudio-bluetooth` for the first time, make sure to restart it. Check status `pulseaudio --check`, kill process `pulseaudio -k`, start as daemon `pulseaudio -D`.

1. `systemctl status bluetooth.service`, make sure bluetooth service is running.
2. Run `bluetoothctl`. (no need for root)
3. Within `bluetoothctl`, execute one-by-one: `power on`, `agent on`, `default-agent`, `scan on`.
4. Search for the bluetooth device to connect, e.g. `Device 00:1D:43:6D:03:26 Lasmex LBT10`, we need the mac address of the device.
4. Get info of the device if you want with `info 00:1D:43:6D:03:26`.
5. Pair the device with `pair 00:1D:43:6D:03:26`.
6. Connect the device with `connect 00:1D:43:6D:03:26`.
7. Auto connect in the future with `trust 00:1D:43:6D:03:26`.
8. Disable scan `scan off` and `exit` bluetoothctl.
9. Run `bluetoothctl devices` to see all available devices.
10. Run `pavucontrol`, a GTK based volume control tool, for volume control. 
11. (Optional) Install `alsa-utils` package to use `amixer`.


# Setup hibernation on Arch Linux

> https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation
> https://github.com/White-Oak/arch-setup-for-dummies

**Configuration**

1. Configure boot loader.
   
   With GRUB:
   
   - Run `lsblk` to get all partitions, and run `sudo blkid` to get UUID of partitions. Get the PARTUUID of the swap partition.
   - Run `sudoedit /etc/default/grub`.
   - Find the string containing `GRUB_CMDLINE_LINUX_DEFAULT='quiet'`. (Value can be anything instead of 'quiet')
   - Insert `resume=UUID=yourSwapPartitionUUID` into quotes.
   - Example result: `GRUB_CMDLINE_LINUX_DEFAULT='quiet resume=UUID=c55290c5-c2d9-4135-b0d7-498eb22b653d'`.
   - Run `sudo grub-mkconfig -o /boot/grub/grub.cfg` to generate grub config.

   With Systemd-boot:

   - Just ensure the swap partition exists and already mounted, nothing more needed.

2. Configure initramfs generator.
   
   - Run `sudoedit /etc/mkinitcpio.conf`.
   - Find the line that looks like this: `HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)`. It's located in the section named HOOKS.
   - Insert hook `resume` after `filesystems`. (Like this: `..filesystems resume..`)
   - Run `sudo mkinitcpio -P` to generate initramfs.

3. Run `systemctl hibernate` to hibernate.

4. (Optional) Configuring "logind.conf".

   - Run `sudoedit /etc/systemd/logind.conf`.
   - Set "HandlePowerKey=hibernate".
   - Set "HandleLidSwitch=suspend-then-hibernate".

5. (Optional) Configuring "sleep.conf".

   - Run `sudoedit /etc/systemd/sleep.conf`.
   - Set "AllowSuspendThenHibernate=yes".
   - Set "HibernateDelaySec=14400".

6. (Optional) Configure image size for hibernation.

   - Default image size is set in `/sys/power/image_size`, you can change the value inside of it.
   - Set desired image size value in `/etc/tmpfiles.d/hibernation_image_size.conf` to make the change persistent.

# Shell startup hierarchy

**Bash startup sequence**:

- /etc/profile (system-wide, login shells)
- ~/.profile (user-specific, login shells)
- ~/.bash_profile (user-specific, login shells, overrides ~/.profile if exists)
- ~/.bash_login (user-specific, login shells, used if ~/.bash_profile doesn't exist)
- /etc/bash.bashrc (system-wide, interactive non-login shells)
- ~/.bashrc (user-specific, interactive non-login shells)
- /etc/bash.bash_logout (system-wide, login shells at exit)
- ~/.bash_logout (user-specific, login shells at exit)

**Zsh startup sequence**:

- /etc/zshenv (system-wide)
- ~/.zshenv (user-specific)
- /etc/zprofile (system-wide, login shells)
- ~/.zprofile (user-specific, login shells)
- /etc/zshrc (system-wide, interactive)
- ~/.zshrc (user-specific, interactive)
- /etc/zlogin (system-wide, login shells)
- ~/.zlogin (user-specific, login shells)
- /etc/zlogout (system-wide, login shells at exit)
- ~/.zlogout (user-specific, login shells at exit)

# Neovim

Install latex tree-sitter parser:

> Actually I don't use tree-sitter parser for latex, I use vimtex for syntax highlighing.

It's a bit complicated, you need to install `tree-sitter` and `tree-sitter-cli` packages with pacman, and also install node.

Latex parser need to be generated from javascript source (i.e. :TSInstallFromGrammar), normal :TSInstall does not require the tree-sittter cli.

The tree-sitter executable is not needed for almost all parsers, we only need it when we need to generate parsers from grammar.js files (e.g. latex parser).
