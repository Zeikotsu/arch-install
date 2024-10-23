#!/bin/bash
bash ./init.sh
cp -rp stage1.sh /mnt/tmp/
arch-chroot /mnt bash /mnt/tmp/stage1.sh