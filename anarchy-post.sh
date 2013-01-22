#!/bin/bash
# encoding: utf-8

source anarchy.conf

# Hostname
echo "Configuring Hostname..."
echo $HOSTN > /etc/hostname
echo "Configuring Hosts..."
cp /etc/hosts /etc/hosts.bkp
sed -i 's/localhost$/localhost '$HOSTN'/' /etc/hosts

# Keybord Layout
echo "Configuring Keyboard layout..."
echo 'KEYMAP='$KEYBOARD_LAYOUT > /etc/vconsole.conf
echo 'FONT=lat0-16' >> /etc/vconsole.conf
echo 'FONT_MAP=' >> /etc/vconsole.conf

# Locale locale.gen
echo "Configuring locale..."
cp /etc/locale.gen /etc/locale.gen.bkp
sed -i 's/^#'$LANGUAGE'/'$LANGUAGE/ /etc/locale.gen
locale-gen

# Locale locale.conf
export LANG=$LANGUAGE'.utf-8'
echo 'LANG='$LANGUAGE'.utf-8' > /etc/locale.conf
echo 'LC_COLLATE=C' >> /etc/locale.conf
echo 'LC_TIME='$LANGUAGE'.utf-8' >> /etc/locale.conf

# Time zone
echo "Configuring time zone..."
ln -s /usr/share/zoneinfo/$LOCALE /etc/localtime
echo $LOCALE > /etc/timezone
hwclock --systohc --utc

# Setting Network (DHCP via renamed eth0)
echo "Configuring interfaces..."
ETH_NAME=`udevadm test-builtin net_id /sys/class/net/eth0 2> /dev/null | grep NAME_PATH | cut -d= -f2`
cp /etc/network.d/examples/ethernet-dhcp /etc/network.d/
sed -i "s/eth0/$ETH_NAME/" /etc/network.d/ethernet-dhcp
sed -i "s/eth0/$ETH_NAME/" /etc/conf.d/netcfg 
echo 'AUTO_PROFILES=("ethernet-dhcp")' >> /etc/conf.d/netcfg

echo "Enabling Netdf@ethernet-dhcp..."
systemctl enable netcfg@ethernet-dhcp.service

# Create an initial ramdisk environment
echo "Creating initial ramdisk..."
mkinitcpio -p linux

# Install and setting up GRUB Legacy
echo "Installing grub..."
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Setting root password
echo "Changing root password..."
echo -e $ROOT_PASSWD"\n"$ROOT_PASSWD | passwd
