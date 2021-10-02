# Configure recipe for CubeMX
inherit cubemx-stm32mp
inherit resin-u-boot

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
FILESEXTRAPATHS_append := ":${THISDIR}/files"

UBOOT_KCONFIG_SUPPORT = "1"

# The env integration patch had to be reworked
SRC_URI_remove = "${INTEGRATION_KCONFIG_PATCH}"
SRC_URI_append = " \
	file://0001-increase-env-size.patch \
	file://0002-resin-specific-env-integration-kconfig-REWORKED.patch \
	file://0003-bootcmd-resin-integration.patch \
	"

# We require these uboot config options to be enabled for env_resin.h
SRC_URI += "file://balenaos_uboot.cfg"
SRC_URI += "${@bb.utils.contains('DISTRO_FEATURES', 'development-image', '', 'file://balenaos_uboot_prod.cfg', d)}"
SRC_URI += "${@bb.utils.contains('OS_DEV_UBOOT_DELAY', '1', 'file://balenaos_uboot_delay.cfg', 'file://balenaos_uboot_nodelay.cfg', d)}"

CUBEMX_DTB_PATH_UBOOT ?= "u-boot"
CUBEMX_DTB_PATH = "${CUBEMX_DTB_PATH_UBOOT}"
CUBEMX_DTB_SRC_PATH ?= "arch/arm/dts"

BALENA_BOOT_PART = "2"
BALENA_DEFAULT_ROOT_PART  = "3"

################################################################################
# Appending config_resin.h to configure U-Boot environment.
# See also: u-boot-stm32mp patches to add env_resin.h
################################################################################
# Must be one of UBOOT_DEVICETREE (The same as KERNEL_DEVICETREE)
UBOOT_DEFAULT_DEVICETREE_qsmp1570-qsbase1 ?= "stm32mp157c-qsmp1570-mx.dtb"
# These will be added to resin_env.h. See resin-u-boot.bbclass
UBOOT_VARS_append = " KERNEL_IMAGETYPE \
                     UBOOT_DEFAULT_DEVICETREE \
                     "
# Add serial console parameter, Default should be "console=ttySTM0,115200"
U_BOOT_SERIAL_CONSOLE = "console=${@d.getVar('SERIAL_CONSOLE').split()[1]},${@d.getVar('SERIAL_CONSOLE').split()[0]}"
OS_KERNEL_CMDLINE_append = " ${@bb.utils.contains('DEVELOPMENT_IMAGE','1', '${U_BOOT_SERIAL_CONSOLE}', '',d)}"
# resin-rootA fs type
OS_KERNEL_CMDLINE_append = " rootfstype=ext4 "

# Initramfs debugging
#OS_KERNEL_CMDLINE_append = " verbose shell-debug "
OS_KERNEL_CMDLINE_append = " ${@bb.utils.contains('DEVELOPMENT_IMAGE','1', 'debug', '',d)}"
# Initramfs shell
#OS_KERNEL_CMDLINE_append = " shell "

################################################################################
# Configuration for ST's extlinux generation.
# We currently don't use extlinux but configure it just in case.
# See st-machine-extlinux-config-stm32mp.inc and extlinuxconf-stm32mp.bbclass
################################################################################
#
#UBOOT_EXTLINUX_ROOT_target-sdcard = "root=/dev/mmcblk0p5"
#UBOOT_EXTLINUX_ROOT_target-emmc = "root=/dev/mmcblk1p3"
#UBOOT_SPLASH_IMAGE = "../splash/balena-logo.png"

# config_defaults.h does no longer exist
do_inject_config_resin () {
}
