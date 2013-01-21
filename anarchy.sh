#!/bin/bash
# encoding: utf-8


#################################################
#            Warning                            #
#                                               #
#  This is script is TOTALLY outdated. We are   #
# working hard to fix them and put this project #
# up and running.                               #
#                                               #
#  If you're willing to help, please submit and #
# push request.                                 #
#                                               #
# Happy hacking and long live Rock n' Roll      #
#                                               #
#################################################



##################################################
#           Variables                            #
##################################################
# Hostname
HOSTN=Arch

# Time zone
# Available time zones and subzones can be found in the /usr/share/zoneinfo/<Zone>/<SubZone> directories. 
LOCALE=America/Sao_Paulo

# Root password
ROOT_PASSWD=123

########## Variables To Disk Partitioning
# WARNING, this script delete ALL the contents of the disc specified in $ HD.
HD=/dev/sda
# Boot partition size: /boot
BOOT_SIZE=200
# Root partition size: /
ROOT_SIZE=10000
# Swap partition size:
SWAP_SIZE=2000
# The / home partition will occupy the remaining free disk space

# File Systems
BOOT_FS=ext4
HOME_FS=ext4
ROOT_FS=ext4

# Extra packages (not required)
EXTRA_PKGS='vim'

# Keyboard Layout
KEYBOARD_LAYOUT=br-abnt2

# Language
LANGUAGE=pt_BR

######## Auxiliary variables. SHOULD NOT BE CHANGED
BOOT_START=1
BOOT_END=$(($BOOT_START+$BOOT_SIZE))

SWAP_START=$BOOT_END
SWAP_END=$(($SWAP_START+$SWAP_SIZE))

ROOT_START=$SWAP_END
ROOT_END=$(($ROOT_START+$ROOT_SIZE))

HOME_START=$ROOT_END

##################################################
#           functions                            #
##################################################
function inicializa_hd
{
    echo "Initializing HD"
    # Setting the type of partition table (Skipping errors)
    parted -s $HD mklabel msdos &> /dev/null

    # Remove ALL partitions
    parted -s $HD rm 1 &> /dev/null
    parted -s $HD rm 2 &> /dev/null
    parted -s $HD rm 3 &> /dev/null
    parted -s $HD rm 4 &> /dev/null
}

function particiona_hd
{
    ERR=0
    # Create Boot partition
    echo "Creating Boot partition"
    parted -s $HD mkpart primary $BOOT_FS $BOOT_START $BOOT_END 1>/dev/null || ERR=1
    parted -s $HD set 1 boot on 1>/dev/null || ERR=1

    # Create Swap partition
    echo "Creating Swap partition"
    parted -s $HD mkpart primary linux-swap $SWAP_START $SWAP_END 1>/dev/null || ERR=1

    # Create Root partition
    echo "Creating Root partition"
    parted -s $HD mkpart primary $ROOT_FS $ROOT_START $ROOT_END 1>/dev/null || ERR=1

    # Create Home partition
    echo "Creating Home partition"
    parted -s -- $HD mkpart primary $HOME_FS $HOME_START -0 1>/dev/null || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Partition error"
        exit 1
    fi
}

function cria_fs
{
    ERR=0
    # Formats root, boot and home partitions to the specified File System
    echo "Formatting Boot partition"
    mkfs.$BOOT_FS /dev/sda1 -L Boot 1>/dev/null || ERR=1
    echo "Formatting Root partitiont"
    mkfs.$ROOT_FS /dev/sda3 -L Root 1>/dev/null || ERR=1
    echo "Formatting Home partition"
    mkfs.$HOME_FS /dev/sda4 -L Home 1>/dev/null || ERR=1
    # Create and initializes the swap
    echo "Formatting Swap partition"
    mkswap /dev/sda2 || ERR=1
    swapon /dev/sda2 || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "File Systems error"
        exit 1
    fi
}

function monta_particoes
{
    ERR=0
    echo "Mounting partitions"
    # Mount Root partition
    mount /dev/sda3 /mnt || ERR=1
    # Mount Boot partition
    mkdir /mnt/boot || ERR=1
    mount /dev/sda1 /mnt/boot || ERR=1
    # Mount Home partition
    mkdir /mnt/home || ERR=1
    mount /dev/sda4 /mnt/home || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Mounting error"
        exit 1
    fi
}

function configurando_pacman
{
    echo "Setting Pacman"
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bkp
    sed -i "s/^Ser/#Ser/" /etc/pacman.d/mirrorlist
    sed -i '/Brazil/{n;s/^#//}' /etc/pacman.d/mirrorlist

    if [ "$(uname -m)" = "x86_64" ]
    then
        cp /etc/pacman.conf /etc/pacman.conf.bkp
        # Add Multilib 
        sed -i '/^#\[multilib\]/{s/^#//;n;s/^#//;n;s/^#//}' /etc/pacman.conf

    fi
}

function instalando_sistema
{
    ERR=0
    echo "Running pacstrap base base-devel"
    pacstrap /mnt base base-devel || ERR=1
    echo "Running pacstrap grub-bios $EXTRA_PKGS"
    pacstrap /mnt grub-bios `echo $EXTRA_PKGS` || ERR=1
    echo "Running genfstab"
    genfstab -p /mnt >> /mnt/etc/fstab || ERR=1

    if [[ $ERR -eq 1 ]]; then
        echo "Install error"
        exit 1
    fi
}

##################################################
#           Script                               #
##################################################
# Load Keybord Layout
loadkeys $KEYBOARD_LAYOUT

#### Partitioning
inicializa_hd
particiona_hd
cria_fs
monta_particoes

#### Installing
configurando_pacman
instalando_sistema

#### Chroot and configure the base system
arch-chroot /mnt << EOF
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

# Create an initial ramdisk environment
mkinitcpio -p linux

# Install and setting up GRUB Legacy
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Setting root password
echo -e $ROOT_PASSWD"\n"$ROOT_PASSWD | passwd
EOF

echo "Umounting partitions"
umount /mnt/{boot,home,}
reboot
