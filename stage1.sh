pacman-key --init
pacman-key --populate archlinuxarm

ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
locale-gen
echo -n "LANG=en_US.UTF-8" >> /etc/locale.conf
echo -n "KEYMAP=fr-latin9" >> /etc/vconsole.conf
echo -n "arch" >> /etc/hostname

# GRUB
grub-install --efi-directory=/boot --bootlaoder-id=GRUB