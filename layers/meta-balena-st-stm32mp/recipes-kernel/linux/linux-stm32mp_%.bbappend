# Configure recipe for CubeMX
inherit cubemx-stm32mp
inherit kernel-resin

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
	file://0001-stm32mp151-bugfix.patch \
	file://0002-pinctrl-z.patch \
	file://0003-smsc-suspend-bugfix.patch \
	file://0004-stmmac-pinctrl-bugfix.patch \
	file://0005-stmmac-gpio-bugfix.patch \
	file://0009-dwc2-usbotg-bugfix.patch \
	file://0010-stm32-cpufreq-bugfix.patch \
	file://0011-usb-ohci-wakeup-source-suspend.patch \
"

CUBEMX_DTB_PATH_LINUX ?= "kernel"
CUBEMX_DTB_PATH = "${CUBEMX_DTB_PATH_LINUX}"

CUBEMX_DTB_SRC_PATH ?= "arch/arm/boot/dts"