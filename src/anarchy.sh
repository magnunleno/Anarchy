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

source anarchy.conf

##################################################
#           functions                            #
##################################################
function initialize_harddrive
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

function make_partitions
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

function make_fs
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

function mount_partitions
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

function configure_pacman
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

function install_system
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

while true; do
    read -p "This script will erase all your '$HD' data. Do you want to proceed [y/n]? " yn
    case $yn in
        [Yy]* ) echo "We warned you..."; break;;
        [Nn]* ) echo "OK. Bye..."; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

#### Partitioning
initialize_harddrive
make_partitions
make_fs
mount_partitions

#### Installing
configure_pacman
install_system

### Copy necessary files
cp anarchy.conf /mnt/
cp anarchy-post.sh /mnt/

#### Chroot and configure the base system
arch-chroot /mnt << EOF
./anarchy-post.sh
rm anarchy-post.sh anarchy.conf
EOF

echo "Umounting partitions"
umount /mnt/{boot,home,}
reboot
