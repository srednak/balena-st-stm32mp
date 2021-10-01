do_install() {
    mkdir -p ${D}/boot
    for type in ${KERNEL_IMAGETYPE}; do
        install -m 0644 ${DEPLOY_DIR_IMAGE}/kernel/${type}-initramfs-${MACHINE}.bin ${D}/boot/${type}
    done
}