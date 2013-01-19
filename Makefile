# TODO: Check for the pkg squashfs-tools

BUILD_DIR=./build
CUSTOM_ISO_DIR=$(BUILD_DIR)/custom_iso
ISO_MOUNT_DIR=$(BUILD_DIR)/mnt/archiso
ROOTFS_32=$(BUILD_DIR)/mnt/rootfs_32
ROOTFS_64=$(BUILD_DIR)/mnt/rootfs_64

build-all: _base build-32 build-64

build-32: _base
	mkdir -p $(ROOTFS_32)

	cp $(CUSTOM_ISO_DIR)/arch/i686/root-image.fs.sfs $(BUILD_DIR)/root-image-i686
	cd $(BUILD_DIR)/root-image-i686 && unsquashfs root-image.fs.sfs

	sudo mount $(BUILD_DIR)/root-image-i686/squashfs-root/root-image.fs $(ROOTFS_32)
	sudo cp anarchy.sh $(ROOTFS_32)/root/
	sudo umount $(ROOTFS_32)


build-64: _base
	mkdir -p $(ROOTFS_64)

	cp $(CUSTOM_ISO_DIR)/arch/x86_64/root-image.fs.sfs $(BUILD_DIR)/root-image-x86_64
	cd $(BUILD_DIR)/root-image-x86_64 && unsquashfs root-image.fs.sfs

	sudo mount $(BUILD_DIR)/root-image-x86_64/squashfs-root/root-image.fs $(ROOTFS_64)
	sudo cp anarchy.sh $(ROOTFS_64)/root/
	sudo umount $(ROOTFS_64)


_base:
	mkdir -p $(ISO_MOUNT_DIR)
	mkdir -p $(CUSTOM_ISO_DIR)
	mkdir $(BUILD_DIR)/root-image-i686
	mkdir $(BUILD_DIR)/root-image-x86_64

	sudo mount -t iso9660 -o loop ./archlinux-2013.01.04-dual.iso $(ISO_MOUNT_DIR)
	cp -a $(ISO_MOUNT_DIR)/* $(CUSTOM_ISO_DIR)


clean:
	-sudo umount $(ISO_MOUNT_DIR)
	-sudo umount $(ROOTFS_32)
	-sudo umount $(ROOTFS_64)
	rm -rf $(BUILD_DIR)/*
