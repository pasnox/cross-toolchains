#!/bin/bash

# mtdev, libevdev, libinput, xcb-proto, xcb

# $1: Message
# $2: Exit code
function die() {
    echo ${1}
    exit ${2}
}

SCRIPT_PWD=`dirname "${0}"`
. ${SCRIPT_PWD}/build-constants.sh || die "Can't source constants" 1

./configure \
    --prefix ${CROSS_DEVICE_OPTWARES_PATH} \
    --host=${CROSS_DEVICE_VENDOR} \
    --with-sysroot=${CROSS_DEVICE_SDK_PATH} \
    "$@" \
    || die "Can't configure" 2

make -j ${CROSS_MAKE_JOBS} || die "Can't make" 3
make -j ${CROSS_MAKE_JOBS} install || die "Can't make install" 4
echo "Done."
