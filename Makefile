UNSQUASHFS := $(shell which unsquashfs)
GENISOIMAGE := $(shell which genisoimage)

BUILD_DIR=./build
CUSTOM_ISO_DIR=$(BUILD_DIR)/custom_iso
ISO_MOUNT_DIR=$(BUILD_DIR)/mnt/archiso

ROOT_IMG32=$(BUILD_DIR)/root-image-i686
ROOT_IMG64=$(BUILD_DIR)/root-image-x86_64

ROOTFS_32=$(BUILD_DIR)/mnt/rootfs_32
ROOTFS_64=$(BUILD_DIR)/mnt/rootfs_64

OUTPUT_ISO=$(BUILD_DIR)/out

LABEL=ANARCHY_$(shell date +%Y%m)

ARCH_LABEL := $(shell iso-info -d -i $(ISO) | grep "Volume" | cut -c15-25)

build-all: build-64 iso clean

build-32:
	@echo "#############################"
	@echo "Starting i686 customization..."
	@mkdir -p $(ROOTFS_32)
	@mkdir $(ROOT_IMG32)

	@cp $(CUSTOM_ISO_DIR)/arch/i686/root-image.fs.sfs $(ROOT_IMG32)
	@echo -n "Unsquasing root image..."
	@cd $(ROOT_IMG32) && unsquashfs root-image.fs.sfs > /dev/null
	@cd $(ROOT_IMG32) && rm root-image.fs.sfs
	@echo " OK"

	@echo "Mounting Root Image..."
	@sudo mount $(ROOT_IMG32)/squashfs-root/root-image.fs $(ROOTFS_32)
	@echo -n "Copying files..."
	@sudo cp src/* $(ROOTFS_32)/root/
	@echo " OK"

	@echo "Umounting image..."
	@sudo umount $(ROOTFS_32)

	@echo -n "Squashing new image...."
	@cd $(ROOT_IMG32) && mksquashfs squashfs-root root-image.fs.sfs
	@echo " OK"

	@echo "Copying the new root-image"
	@cp $(ROOT_IMG32)/root-image.fs.sfs $(CUSTOM_ISO_DIR)/arch/i686/root-image.fs.sfs

	@echo "#############################"
	@echo " *** Finished successfully the i686 customizations!"
	@echo ""


build-64: _base
	@echo "#############################"
	@echo "Starting x86_64 customization..."
	@mkdir -p $(ROOTFS_64)
	@mkdir $(ROOT_IMG64)

	@cp $(CUSTOM_ISO_DIR)/arch/x86_64/airootfs.sfs $(ROOT_IMG64)
	@echo -n "Unsquasing root image..."
	@cd $(ROOT_IMG64) && unsquashfs airootfs.sfs 2> /dev/null
	@cd $(ROOT_IMG64) && rm airootfs.sfs
	@echo " OK"

	@echo -n "Copying files..."
	@sudo cp *.sh $(ROOT_IMG64)/squashfs-root/root/
	@sudo cp *.conf $(ROOT_IMG64)/squashfs-root/root/
	@echo " OK"

	@echo -n "Squashing new image...."
	@cd $(ROOT_IMG64) && mksquashfs squashfs-root airootfs.sfs
	@echo " OK"

	@echo -n "Generating new MD5...."
	@cd $(ROOT_IMG64) && md5sum airootfs.sfs > airootfs.md5
	@echo " OK"

	@echo "Copying the new root-image"
	@cp $(ROOT_IMG64)/airootfs.sfs $(CUSTOM_ISO_DIR)/arch/x86_64/airootfs.sfs

	@echo "#############################"
	@echo " *** Finished successfully the x86_64 customizations!"
	@echo ""


iso:
ifeq (GENISOIMAGE,)
	$(error genisoimage command not found! Please install the cdrkit package.)
endif
	@echo "#############################"
	@echo "Building new ISO..."
	@genisoimage -l -r -J -V $(ARCH_LABEL) -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -c isolinux/boot.cat -o ./build/out/snackk-archlinux-`date +%Y.%m.%d`-dual.iso $(CUSTOM_ISO_DIR)
	@sudo chmod a+rw ./build/out/*

	@echo "#############################"
	@echo " *** Finished the new ISO!"
	@echo ""


_base:
ifeq (UNSQUASHFS,)
	$(error unsquashfs command not found! Please install the squashfs-tools package.)
endif
ifeq ($(ISO),)
	$(error Please specify the Arch Linux ISO full path.)
endif
	@echo -n "Building base dirs..."
	@mkdir -p $(ISO_MOUNT_DIR)
	@mkdir -p $(CUSTOM_ISO_DIR)
	@mkdir -p $(OUTPUT_ISO)
	@echo " OK"

	@echo "Mounting ISO"
	@sudo mount -t iso9660 -o loop $(ISO) $(ISO_MOUNT_DIR)
	@echo -n "Copying files..."
	@cp -a $(ISO_MOUNT_DIR)/* $(CUSTOM_ISO_DIR)
	@-sudo umount $(ISO_MOUNT_DIR)
	@echo -n " Umounting ISO"
	@echo -n " OK"
	@echo ""

clean:
	@echo "Cleaning files..."
	@-sudo umount $(ROOTFS_64) 2> /dev/null
	@-sudo umount $(ROOTFS_32) 2> /dev/null
	@cp $(OUTPUT_ISO)/* .  2> /dev/null
	@-sudo rm -rf $(BUILD_DIR)/*  2> /dev/null
	@echo "All done!" 
	@echo ""
