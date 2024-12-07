# Enable hibernation on Arch Linux

> Credit: https://github.com/White-Oak/arch-setup-for-dummies

**Configuration**

1. Configure boot loader.
   
   With GRUB:
   
   - Run `lsblk` to get all partitions, and run `sudo blkid` to get UUID of partitions. Get the PARTUUID of the swap partition.
   - `sudoedit /etc/default/grub`
   - Find the string containing `GRUB_CMDLINE_LINUX_DEFAULT='quiet'`. (Value can be anything instead of 'quiet')
   - Insert `resume=UUID=yourSwapPartitionUUID` into quotes.
   - Example result: `GRUB_CMDLINE_LINUX_DEFAULT='quiet resume=UUID=c55290c5-c2d9-4135-b0d7-498eb22b653d'`.
   - Run `sudo grub-mkconfig -o /boot/grub/grub.cfg` to generate grub config.

2. Configure initramfs generator.
   
   - `sudoedit /etc/mkinitcpio.conf`
   - Find the line that looks like this: `HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)`. It's located in the section named HOOKS.
   - Insert hook `resume` after `udev`. (Like this: `..base udev resume..`)
   - Run `sudo mkinitcpio -p linux` to generate initramfs.

3. Run `systemctl hibernate` to hibernate.

**Explanation**

UUID of swap partition tells the kernel where to look for hibernation data. Parameter `resume=UUID=...` is passed to kernel at boot time.

Initramfs is a temporary root filesystem used during boot. The `resume` hook must be added after `udev`, because `udev` creates device nodes and handles hardware detection, `resume` hook needs device nodes to exist to find and read the swap partition, `resume` must run before mounting the real root filesystem to ensure proper state restoration.

Order of Operations During Resume:

1. GRUB loads kernel and initramfs with `resume` parameter
2. Kernel starts and runs initramfs
3. `udev` hook sets up devices
4. `resume` hook checks swap partition for hibernation signature
5. If found, restores system state from swap
6. If no hibernation data found, continues normal boot
7. Remaining hooks run to mount filesystems and complete boot

