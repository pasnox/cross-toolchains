#!/bin/bash

. build-constants.sh

if [ ! -d "${1}" ]; then
    echo "Please give the Qt sources folder to build as first parameter."
    exit 1
fi

CROSS_DEVICE_MKSPEC="linux-open-pandora-g++"
QT_VERSION="`basename \"${1}\"`"
QT_VERSION="`echo \"${QT_VERSION}\" | cut -d'-' -f5`"
QT_WILDCARD_VERSION="`echo \"${QT_VERSION}\" | cut -d'.' -f1,2`.x"

CUR_PWD="${PWD}"

if [ -L "${1}/mkspecs/${CROSS_DEVICE_MKSPEC}" ]; then
    rm -f "${1}/mkspecs/${CROSS_DEVICE_MKSPEC}"
fi

if [ -d "${1}/mkspecs/${CROSS_DEVICE_MKSPEC}" ]; then
    rm -fr "${1}/mkspecs/${CROSS_DEVICE_MKSPEC}"
fi

cp -r "${PWD}/Qt/mkspecs/${QT_WILDCARD_VERSION}/${CROSS_DEVICE_MKSPEC}" "${1}/mkspecs/"

cd "${1}"

# fix dbus test
echo "LIBS *= -ldbus-1" >> "config.tests/unix/dbus/dbus.pro"

./configure \
-arch arm \
-xplatform "${CROSS_DEVICE_MKSPEC}" \
-nomake examples \
-nomake demos \
-make tools \
-fast \
-no-pch \
-no-qt3support \
-no-webkit \
-opengl es2 \
-platform linux-g++-64 \
-prefix "${CROSS_DEVICE_OPTWARES_PATH}/../Qt/${QT_VERSION}" \
-opensource \
-confirm-license \
&& make -j 4 \
&& make install

cd "${CUR_PWD}"
