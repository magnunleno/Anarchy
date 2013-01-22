#!/bin/bash
# encoding: utf-8

source anarchy.conf

# Hostname
echo $HOSTN > /etc/hostname
cp /etc/hosts /etc/hosts.bkp
sed -i 's/localhost$/localhost '$HOSTN'/' /etc/hosts

# Keybord Layout
echo 'KEYMAP='$KEYBOARD_LAYOUT > /etc/vconsole.conf
echo 'FONT=lat0-16' >> /etc/vconsole.conf
echo 'FONT_MAP=' >> /etc/vconsole.conf

# Locale locale.gen
cp /etc/locale.gen /etc/locale.gen.bkp
sed -i 's/^#'$LANGUAGE'/'$LANGUAGE/ /etc/locale.gen
locale-gen

# Locale locale.conf
export LANG=$LANGUAGE'.utf-8'
echo 'LANG='$LANGUAGE'.utf-8' > /etc/locale.conf
echo 'LC_COLLATE=C' >> /etc/locale.conf
echo 'LC_TIME='$LANGUAGE'.utf-8' >> /etc/locale.conf

# Time zone
ln -s /usr/share/zoneinfo/$LOCALE /etc/localtime
echo $LOCALE > /etc/timezone
hwclock --systohc --utc

# Setting Network (DHCP via eth0)
# systemctl enable dhcpcd@eth0.service
# Thanks to SystemD latest update the interfaces are now
# receiveing unpredictable names
ETH_NAME=`udevadm test-builtin net_id /sys/class/net/eth0 2> /dev/null | grep NAME_PATH | cut -d= -f2`
sed -i "s/eth0/$ETH_NAME/" /etc/conf.d/netcfg 
systemctl enable net-auto-wired.service

# Create an initial ramdisk environment
mkinitcpio -p linux

# Install and setting up GRUB Legacy
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Setting root password
echo -e $ROOT_PASSWD"\n"$ROOT_PASSWD | passwd
