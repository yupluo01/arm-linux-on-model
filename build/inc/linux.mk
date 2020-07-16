CPIO_BIN = $(TOP_DIR)/linux/out/usr/gen_init_cpio 

linux.build:
	export ARCH=arm64; \
	export CROSS_COMPILE=$(CROSS_COMPILE) ; \
	cd linux ; \
	mkdir -p out ;\
	make O=out/ defconfig ; \
	make O=out/ -j $(JOBS) Image dtbs ; \


linux.clean:
	rm linux/out -rf 

