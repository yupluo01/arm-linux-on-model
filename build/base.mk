MODEL  ?= FVP_Base_RevC-2xAEMv8A
TFTF   ?= 0
TTBR   ?= 0
OPTEE  ?= 0

ARCH_HAS_ARMV8_1 ?= 1
ARCH_HAS_ARMV8_2 ?= 1
ARCH_HAS_ARMV8_3 ?= 1
ARCH_HAS_ARMV8_4 ?= 1
ARCH_HAS_ARMV8_5 ?= 1
ARCH_HAS_ARMV8_6 ?= 1
HAS_BTI ?= 1 
MTE_LEVEL ?= 2 
CLUSTER0_NUM_CORES ?= 4
CLUSTER1_NUM_CORES ?= 4
CACHE_STATE_MODELLED ?= 1

# ATF
DTB = fvp-base-gicv3-psci-1t.dts
DTB = fvp-base-gicv3-psci-dynamiq.dts

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

TF_CONFIG   = PLAT=fvp FVP_HW_CONFIG_DTS=fdts/$(DTB)

include ${MK_INC_DIR}cmn.mk
include ${MK_INC_DIR}u-boot.mk
include ${MK_INC_DIR}tftf.mk
include ${MK_INC_DIR}optee.mk
include ${MK_INC_DIR}arm-tf.mk
include ${MK_INC_DIR}linux.mk
include ${MK_INC_DIR}busybox.mk
include ${MK_INC_DIR}ramdisk.mk

ARCH_PARAMS = \
	     -C cluster0.has_arm_v8-1=$(ARCH_HAS_ARMV8_1)  \
	     -C cluster0.has_arm_v8-2=$(ARCH_HAS_ARMV8_2)  \
	     -C cluster0.has_arm_v8-3=$(ARCH_HAS_ARMV8_3)  \
	     -C cluster0.has_arm_v8-4=$(ARCH_HAS_ARMV8_4)  \
	     -C cluster0.has_arm_v8-5=$(ARCH_HAS_ARMV8_5)  \
	     -C cluster0.has_arm_v8-6=$(ARCH_HAS_ARMV8_6)  \
	     -C cluster0.has_branch_target_exception=$(HAS_BTI) \
	     -C cluster0.memory_tagging_support_level=$(MTE_LEVEL)  \
	     -C cluster1.has_arm_v8-1=$(ARCH_HAS_ARMV8_1)  \
	     -C cluster1.has_arm_v8-2=$(ARCH_HAS_ARMV8_2)  \
	     -C cluster1.has_arm_v8-3=$(ARCH_HAS_ARMV8_3)  \
	     -C cluster1.has_arm_v8-4=$(ARCH_HAS_ARMV8_4)  \
	     -C cluster1.has_arm_v8-5=$(ARCH_HAS_ARMV8_5)  \
	     -C cluster1.has_arm_v8-6=$(ARCH_HAS_ARMV8_6)  \
	     -C cluster1.has_branch_target_exception=$(HAS_BTI) \
	     -C cluster1.memory_tagging_support_level=$(MTE_LEVEL)  \

MODEL_PARAMS = \
	       -C pctl.startup=0.0.0.0 \
	       -C bp.secure_memory=1   \
	       -C cluster0.NUM_CORES=$(CLUSTER0_NUM_CORES) \
	       -C cluster1.NUM_CORES=$(CLUSTER1_NUM_CORES) \
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
	       $(ARCH_PARAMS)
	       
run:
	$(MODEL) $(MODEL_PARAMS) 

ds5:
	@echo "Model params in DS-5:"
	@echo $(MODEL_PARAMS)
	@echo "" 
	@echo "\r\nDebug symbol in DS-5:"
	@echo "add-symbol-file \"$(TOP_DIR)/arm-tf/build/fvp/debug/bl1/bl1.elf\" EL3:0"
	@echo "add-symbol-file \"$(TOP_DIR)/arm-tf/build/fvp/debug/bl31/bl31.elf\" EL3:0"
	@echo "add-symbol-file \"$(TOP_DIR)/arm-tf/build/fvp/debug/bl2/bl2.elf\" EL1S:0"
	@echo "add-symbol-file \"$(TOP_DIR)/tftf/build/fvp/debug/tftf/tftf.elf\" EL2N:0"
	@echo "add-symbol-file \"$(TOP_DIR)/linux/out/vmlinux\" EL1N:0"

