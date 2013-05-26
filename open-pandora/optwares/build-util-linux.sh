#!/bin/bash

. build-constants.sh

if [ ! -d "${1}" ]; then
    echo "Please give an existing util-linux-ng sources folder as first parameter to this script."
    exit 1
fi

CUR_PWD="${PWD}"

cd "${1}"

./configure \
--host="${CROSS_DEVICE_VENDOR}" \
--prefix="${CROSS_DEVICE_OPTWARES_PATH}" \
--enable-shared \
--enable-static \
--disable-mount \
--disable-losetup \
--disable-fsck \
--disable-partx \
--disable-uuidd \
--disable-mountpoint \
--disable-fallocate \
--disable-unshare \
--disable-eject \
--disable-agetty \
--disable-cramfs \
--disable-wdctl \
--disable-switch_root \
--disable-pivot_root \
--disable-kill \
--disable-utmpdump \
--disable-rename \
--disable-login \
--disable-sulogin \
--disable-su \
--disable-schedutils \
--disable-wall \
--disable-pg-bell \
--disable-require-password \
--disable-use-tty-group \
--disable-makeinstall-chown \
--disable-makeinstall-setuid \
&& \
make V=1 -j ${CROSS_MAKE_JOBS} \
&& \
make install

cd "${CUR_PWD}"
