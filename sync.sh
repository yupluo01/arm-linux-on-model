git clone -b master git://git.busybox.net/busybox busybox
git clone -b 20.04 https://git.linaro.org/landing-teams/working/arm/u-boot
git clone -b master https://github.com/ARMmbed/mbedtls.git
git clone -b master https://git.trustedfirmware.org/TF-A/trusted-firmware-a.git arm-tf
git clone -b master https://git.linaro.org/landing-teams/working/arm/ramdisk

git clone -b master git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git linux
cd linux
git remote add linux-next https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
git fetch linux-next
git checkout master
git remote update
cd ..

#mkdir -p optee
#cd optee
#git clone -b master https://github.com/OP-TEE/optee_os.git
#git clone -b master https://github.com/OP-TEE/optee_os.git
#cd ../
