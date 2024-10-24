pacman-key --init
pacman-key --populate archlinuxarm

ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
locale-gen
echo -n "LANG=en_US.UTF-8" >> /etc/locale.conf
echo -n "KEYMAP=fr-latin9" >> /etc/vconsole.conf
echo -n "arch" >> /etc/hostname

echo -e "archlinux\narchlinux" | passwd 

# GRUB
grub-install --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg