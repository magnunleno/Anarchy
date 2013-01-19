BUILD_DIR=./build
ISO_MOUNT_DIR=$(BUILD_DIR)/mnt/archiso
CUSTOM_ISO_DIR=$(BUILD_DIR)/custom_iso

remaster:
	mkdir -p $(ISO_MOUNT_DIR)
	mkdir -p $(CUSTOM_ISO_DIR)
	sudo mount -t iso9660 -o loop ./archlinux-2013.01.04-dual.iso $(ISO_MOUNT_DIR)
	cp -a $(ISO_MOUNT_DIR)/* $(CUSTOM_ISO_DIR)
	sudo umount $(ISO_MOUNT_DIR)

clean:
	-sudo umount $(ISO_MOUNT_DIR)
	rm -rf $(BUILD_DIR)/*
