#!/bin/bash
loadkeys fr-latin9
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

pacstrap -K /mnt base linux linux-firmware vi archlinuxarm-keyring grub efibootmgr networkmanager
genfstab -U /mnt >> /mnt/etc/fstab
