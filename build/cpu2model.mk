### ARMv8.2 processors
#FVP revC
#make CROSS_COMPILE=aarch64-linux-gnu- PLAT=fvp FVP_HW_CONFIG_DTS=fdts/fvp-base-gicv3-psci-1t.dts DEBUG=1 BL33=../u-boot/output/vexpress_aemv8a_semi/u-boot.bin  dtbs all fip

#v8.2 cpu
#make CROSS_COMPILE=aarch64-linux-gnu- PLAT=fvp FVP_HW_CONFIG_DTS=fdts/fvp-base-gicv3-psci-dynamiq.dts DEBUG=1 BL33=../u-boot/output/vexpress_aemv8a_semi/u-boot.bin CTX_INCLUDE_AARCH32_REGS=0 FVP_MAX_CPUS_PER_CLUSTER=8 USE_COHERENT_MEM=0 HW_ASSISTED_COHERENCY=1 dtbs all fip

#MODEL=FVP_Base_Cortex-A55
#MODEL=FVP_Base_Cortex-A55x1
#MODEL=FVP_Base_Cortex-A55x4
#MODEL=FVP_Base_Cortex-A55x4+Cortex-A75x4
#MODEL=FVP_Base_Cortex-A55x2+Cortex-A75x2
#MODEL=FVP_Base_Cortex-A55x4+Cortex-A76x2
#MODEL=FVP_Base_Cortex-A76x4
#MODEL=FVP_Base_Cortex-A75x4

#MODEL=FVP_Base_Cortex-A65x4
MODEL=FVP_Base_Neoverse-E1x4

#MODEL   = FVP_Base_Kleinx1
#MODEL   = FVP_Base_Kleinx2
#MODEL   = FVP_Base_Kleinx4
#MODEL   = FVP_Base_Kleinx8
#MODEL   = FVP_Base_Matterhornx1
#MODEL   = FVP_Base_Matterhornx2
#MODEL   = FVP_Base_Matterhornx4
TFTF   ?= 0
TTBR   ?= 0
OPTEE  ?= 0

CACHE_STATE_MODELLED ?= 1

ifeq ($(TFTF), 1)
	TARGETS = tftf 
TFTF_TEST ?=standard
else
	TARGETS = u-boot 
endif
ifeq ($(OPTEE), 1)
	TARGETS += optee
endif 

TARGETS += arm-tf 

ifeq ($(TFTF), 0)
TARGETS += linux busybox ramdisk
endif

JOBS 			= $(shell nproc --all)
TOP_DIR 		= $(shell pwd)
MK_INC_DIR		= $(TOP_DIR)/build/inc/

UBOOT_CONFIG 	= vexpress_aemv8a_semi_config 
TF_CONFIG    	= PLAT=fvp \
			FVP_HW_CONFIG_DTS=fdts/fvp-base-gicv3-psci-dynamiq.dts \
			CTX_INCLUDE_AARCH32_REGS=0 FVP_MAX_CPUS_PER_CLUSTER=8 USE_COHERENT_MEM=0 HW_ASSISTED_COHERENCY=1

include ${MK_INC_DIR}cmn.mk
include ${MK_INC_DIR}u-boot.mk
include ${MK_INC_DIR}tftf.mk
include ${MK_INC_DIR}optee.mk
include ${MK_INC_DIR}arm-tf.mk
include ${MK_INC_DIR}linux.mk
include ${MK_INC_DIR}busybox.mk
include ${MK_INC_DIR}ramdisk.mk

#disk_param=" -C bp.virtioblockdevice.image_path=$DISK "

MODEL_PARAMS = \
	       -C pctl.startup=0.0.0.0 \
	       -C bp.secure_memory=1   \
	       -C cache_state_modelled=$(CACHE_STATE_MODELLED) \
	       -C bp.pl011_uart0.untimed_fifos=1  \
	       -C bp.pl011_uart0.unbuffered_output=1  \
	       -C bp.secureflashloader.fname=$(TOP_DIR)/arm-tf/build/fvp/debug/bl1.bin \
	       -C bp.flashloader0.fname=$(TOP_DIR)/arm-tf/build/fvp/debug/fip.bin \
	       --data cluster0.cpu0=$(TOP_DIR)/ramdisk/ramdisk.img@0x84000000 \
	       --data cluster0.cpu0=$(TOP_DIR)/linux/out/arch/arm64/boot/Image@0x80080000  \
	       -C bp.pl011_uart0.out_file=$(TOP_DIR)/uart0.log \
	       -C bp.pl011_uart1.out_file=$(TOP_DIR)/uart1.log \
	       -C bp.ve_sysregs.mmbSiteDefault=0 \
	       -C bp.ve_sysregs.exit_on_shutdown=1  \
	       $(disk_param) \
	
run:
	$(MODEL) $(MODEL_PARAMS) 

ds5:
	@echo "Model params in Arm DS:"
	@echo $(MODEL_PARAMS)
	@echo "" 
	@echo "\r\nDebug symbol in Arm DS:"
	@echo "add-symbol-file \"$(TOP_DIR)/arm-tf/build/fvp/debug/bl1/bl1.elf\" EL3:0"
	@echo "add-symbol-file \"$(TOP_DIR)/arm-tf/build/fvp/debug/bl31/bl31.elf\" EL3:0"
	@echo "add-symbol-file \"$(TOP_DIR)/arm-tf/build/fvp/debug/bl2/bl2.elf\" EL1S:0"
	@echo "add-symbol-file \"$(TOP_DIR)/tftf/build/fvp/debug/tftf/tftf.elf\" EL2N:0"
	@echo "add-symbol-file \"$(TOP_DIR)/linux/out/vmlinux\" EL1N:0"


