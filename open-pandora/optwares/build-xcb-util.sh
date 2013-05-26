#!/bin/bash

. build-constants.sh

if [ ! -d "${1}" ]; then
    echo "Please give an existing xcb-util sources folder as first parameter to this script."
    exit 1
fi

CUR_PWD="${PWD}"

cd "${1}"

./configure \
--host="${CROSS_DEVICE_VENDOR}" \
--prefix="${CROSS_DEVICE_OPTWARES_PATH}" \
--enable-shared \
--enable-static \
&& \
make V=1 -j ${CROSS_MAKE_JOBS} \
&& \
make install

cd "${CUR_PWD}"
