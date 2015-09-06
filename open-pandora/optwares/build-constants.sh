#!/bin/bash

export MAKE=make

export CROSS_DEVICE="open-pandora"
export CROSS_DEVICE_VENDOR="arm-openpandora-linux-gnueabi"
export CROSS_DEVICE_CFLAGS="-marm -mabi=aapcs-linux -O3 -pipe -march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp -ftree-vectorize -fsingle-precision-constant -fsigned-char"
export CROSS_DEVICE_LDFLAGS="-lc_nonshared -ldl"

export CROSS_TOOLCHAINS_PATH="/opt/cross/x-tools"
export CROSS_DEVICE_TOOLCHAIN_PATH="${CROSS_TOOLCHAINS_PATH}/${CROSS_DEVICE}/${CROSS_DEVICE_VENDOR}"
export CROSS_DEVICE_TOOLCHAIN_BIN_PATH="${CROSS_DEVICE_TOOLCHAIN_PATH}/bin"
export CROSS_DEVICE_TOOLCHAIN_BIN_PREFIX_PATH="${CROSS_DEVICE_TOOLCHAIN_PATH}/bin/${CROSS_DEVICE_VENDOR}-"
export CROSS_DEVICE_TOOLCHAIN_SYSROOT_PATH="${CROSS_DEVICE_TOOLCHAIN_PATH}/${CROSS_DEVICE_VENDOR}/sysroot"

export CROSS_DEVICE_SDK_PATH="${CROSS_TOOLCHAINS_PATH}/${CROSS_DEVICE}/Sysroot"
export CROSS_DEVICE_OPTWARES_PATH="${CROSS_TOOLCHAINS_PATH}/${CROSS_DEVICE}/Optwares"

export CROSS_MAKE_JOBS="8"
export PKG_CONFIG_PATH="${CROSS_DEVICE_SDK_PATH}/usr/lib/pkgconfig:${CROSS_DEVICE_SDK_PATH}/usr/share/pkgconfig:${CROSS_DEVICE_SDK_PATH}/usr/lib/${CROSS_DEVICE_VENDOR}/pkgconfig:${CROSS_DEVICE_OPTWARES_PATH}/lib/pkgconfig"
export PKG_CONFIG_SYSROOT_DIR="${CROSS_DEVICE_SDK_PATH}"
export PATH="${CROSS_DEVICE_TOOLCHAIN_BIN_PATH}:${PATH}"

if [ "${1}" != "no-export" ]; then
    export CFLAGS="-I${CROSS_DEVICE_OPTWARES_PATH}/include -I${CROSS_DEVICE_SDK_PATH}/usr/include ${CROSS_DEVICE_CFLAGS}"
    export LDFLAGS="-L${CROSS_DEVICE_OPTWARES_PATH}/lib -L${CROSS_DEVICE_SDK_PATH}/lib -L${CROSS_DEVICE_SDK_PATH}/usr/lib -Wl,-rpath,${CROSS_DEVICE_OPTWARES_PATH}/lib ${CROSS_DEVICE_LDFLAGS}"
fi
