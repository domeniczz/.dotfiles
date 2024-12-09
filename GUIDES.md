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

   With Systemd-boot:

   - Just ensure the swap partition exists and already mounted, nothing more needed.

2. Configure initramfs generator.
   
   - `sudoedit /etc/mkinitcpio.conf`
   - Find the line that looks like this: `HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)`. It's located in the section named HOOKS.
   - Insert hook `resume` after `filesystems`. (Like this: `..filesystems resume..`)
   - Run `sudo mkinitcpio -P` to generate initramfs.

3. Run `systemctl hibernate` to hibernate.

4. (Optional) Configuring "logind.conf".

   - `sudoedit /etc/systemd/logind.conf`
   - Set "HandlePowerKey=hibernate".
   - Set "HandleLidSwitch=suspend-then-hibernate".

5. (Optional) Configuring "sleep.conf".

   - `sudoedit /etc/systemd/sleep.conf`
   - Set "AllowSuspendThenHibernate=yes".
   - Set "HibernateDelaySec=14400".

6. (Optional) Configure image size for hibernation.

   - Default image size is set in `/sys/power/image_size`, you can change the value inside of it.
   - Set desired image size value in `/etc/tmpfiles.d/hibernation_image_size.conf` to make the change persistent.
