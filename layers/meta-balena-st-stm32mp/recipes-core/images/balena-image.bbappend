# The boot device must be GPT-formatted.
PARTITION_TABLE_TYPE = "gpt"
BALENA_BOOT_FAT32 = "1"

IMAGE_FSTYPES_append = " balenaos-img"

#do_rootfs[depends] += " \
#    u-boot-stm32mp-extlinux:do_deploy \
#    "

BALENA_BOOT_PARTITION_FILES_qsmp1570-qsbase1 = " \
    kernel/${KERNEL_IMAGETYPE}${KERNEL_INITRAMFS}-${MACHINE}.bin:/${KERNEL_IMAGETYPE} \
    kernel/stm32mp157c-qsmp1570-mx.dtb:/stm32mp157c-qsmp1570-mx.dtb \
    "
#    extlinux/extlinux.conf:/extlinux/extlinux.conf \
#    "

# See u-boot-stm32mp-extlinux.bbappend about boot.scr.uimg
# BALENA_BOOT_PARTITION_FILES_append_stm32mp1-disco += " \
#     boot.scr.uimg:/boot.scr.uimg \
#     "

# Partition configuration
# Not that the numbers presented here are in units of sectors (512 byte)
# It differes from Balena-image's preferred units (1KiB)
STM32MP1_FSBL1_ALIGNMENT = "34"
STM32MP1_FSBL_SIZE = "512"
STM32MP1_SSBL_SIZE = "4096"

# Write STM32MP1 specific partitions
device_specific_configuration() {
    FSBL_IMG="arm-trusted-firmware/tf-a-stm32mp157c-qsmp1570-mx-emmc.stm32"
    SSBL_IMG="fip/fip-stm32mp157c-qsmp1570-mx-trusted.bin"
	
    # fsbl1
    OPTS="fsbl1"
    START=${STM32MP1_FSBL1_ALIGNMENT}
	END=$(expr ${START} \+ ${STM32MP1_FSBL_SIZE} \- 1)
    parted -s ${BALENA_RAW_IMG} unit s mkpart $OPTS $START $END
    dd if=${DEPLOY_DIR_IMAGE}/$FSBL_IMG of=${BALENA_RAW_IMG} conv=fdatasync,notrunc seek=1 bs=$(expr $START \* 512)
    
    # fsbl2 (a backup copy of fsbl)
    OPTS="fsbl2"
	START=$(expr ${START} \+ ${STM32MP1_FSBL_SIZE})
	END=$(expr ${START} \+ ${STM32MP1_FSBL_SIZE} \- 1)
    parted -s ${BALENA_RAW_IMG} unit s mkpart $OPTS $START $END
    dd if=${DEPLOY_DIR_IMAGE}/$FSBL_IMG of=${BALENA_RAW_IMG} conv=fdatasync,notrunc seek=1 bs=$(expr $START \* 512)

    # fip
    OPTS="fip"
    START=$(expr ${START} \+ ${STM32MP1_FSBL_SIZE})
	END=$(expr ${START} \+ ${STM32MP1_SSBL_SIZE} \- 1)
    parted -s ${BALENA_RAW_IMG} unit s mkpart $OPTS $START $END
    dd if=${DEPLOY_DIR_IMAGE}/$SSBL_IMG of=${BALENA_RAW_IMG} conv=fdatasync,notrunc seek=1 bs=$(expr $START \* 512)

    if [ "$(expr $END \* 512)" -ge "$(expr ${DEVICE_SPECIFIC_SPACE} \* 1024)" ]; then
        bbfatal "STM32MP1 specific space is larger than DEVICE_SPECIFIC_SPACE."
    fi
}

do_copy_partitions_images_to_depoly_dir () {
    install -m 644 ${WORKDIR}/resin-boot.img ${DEPLOY_DIR}/images/${MACHINE}/resin-boot.img
    install -m 644 ${WORKDIR}/resin-rootB.img ${DEPLOY_DIR}/images/${MACHINE}/resin-rootB.img
    install -m 644 ${WORKDIR}/resin-state.img ${DEPLOY_DIR}/images/${MACHINE}/resin-state.img
	ln -sf ${DEPLOY_DIR}/images/${MACHINE}/${IMAGE_BASENAME}-${MACHINE}.${BALENA_ROOT_FSTYPE} ${DEPLOY_DIR}/images/${MACHINE}/resin-rootA.img
}

addtask copy_partitions_images_to_depoly_dir after do_image_balenaos_img before do_image_complete