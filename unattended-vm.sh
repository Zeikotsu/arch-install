#!/bin/bash
# Possible env variables declaration
# ROOT_PASSWORD : root account password
# USER_NAME : primary user account name
# USER_PASSWORD: primary user password

init() {
    #!/bin/bash
    pacman -Sy parted

    # Disk paritionning
    parted /dev/nvme0n1 mklabel gpt 
    parted /dev/nvme0n1 mkpart efi 1MB 1024MB 
    parted /dev/nvme0n1 set 1 esp on 
    parted /dev/nvme0n1 mkpart root 1024MB 5120MB 
    parted /dev/nvme0n1 mkpart home 5120MB 100% 

    # Disk formating
    mkfs.fat -F 32 /dev/nvme0n1p1
    mkfs.ext4 /dev/nvme0n1p2
    mkfs.ext4 /dev/nvme0n1p3

    mount /dev/nvme0n1p3 /mnt
    mount --mkdir /dev/nvme0n1p1 /mnt/boot
    mount --mkdir /dev/nvme0n1p2 /mnt/home
    fallocate -l 1G /mnt/swapfile && chmod 600 /mnt/swapfile && mkswap /mnt/swapfile && swapon /mnt/swapfile

    pacstrap -K /mnt base linux linux-firmware vi archlinuxarm-keyring grub efibootmgr networkmanager gnome gdm wayland zsh
    genfstab -U /mnt >> /mnt/etc/fstab
}

archroot_stage() {
    pacman-key --init
    pacman-key --populate archlinuxarm

    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
    hwclock --systohc
    locale-gen
    echo -n "LANG=en_US.UTF-8" >> /etc/locale.conf
    echo -n "KEYMAP=fr-latin9" >> /etc/vconsole.conf
    echo -n "arch" >> /etc/hostname

    ROOT_PASSWORD=${ROOT_PASSWORD:-archlinux}
    echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd 

    # GRUB
    grub-install --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg

    # NetworkManager
    systemctl enable NetworkManager
    systemctl enable gdm
    localectl set-x11-keymap fr

    # Sudo
    USER_PASSWORD=${USER_PASSWORD:-@rchlinux}
    USER_NAME=${USER_NAME:-user}
    sed -i "s/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers
    useradd -d /home/$USER_NAME -m -s /bin/zsh $USER_NAME
    echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USER_NAME
    usermod -G wheel $USER_NAME
}

# Main routine
init
export -f archroot_stage
arch-chroot /mnt /bin/bash -c "archroot_stage"
