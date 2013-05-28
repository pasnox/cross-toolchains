#!/bin/bash

. build-constants.sh no-export

if [ ! -d "${1}" ]; then
    echo "Please give the Qt sources folder to build as first parameter."
    exit 1
fi

CROSS_DEVICE_MKSPEC="linux-open-pandora-g++"
QT_VERSION="`basename \"${1}\"`"
QT_VERSION="`echo \"${QT_VERSION}\" | cut -d'-' -f5`"
QT_WILDCARD_VERSION="`echo \"${QT_VERSION}\" | cut -d'.' -f1,2`.x"

CUR_PWD="${PWD}"

if [ -L "${1}/qtbase/mkspecs/${CROSS_DEVICE_MKSPEC}" ]; then
    rm -f "${1}/qtbase/mkspecs/${CROSS_DEVICE_MKSPEC}"
fi

if [ -d "${1}/qtbase/mkspecs/${CROSS_DEVICE_MKSPEC}" ]; then
    rm -fr "${1}/qtbase/mkspecs/${CROSS_DEVICE_MKSPEC}"
fi

cp -r "${PWD}/Qt/mkspecs/${QT_WILDCARD_VERSION}/${CROSS_DEVICE_MKSPEC}" "${1}/qtbase/mkspecs/"

cd "${1}"

# fix dbus test/build
echo "LIBS *= -ldbus-1" >> "qtbase/config.tests/unix/dbus/dbus.pro"
echo "INCLUDEPATH *= /usr/include/dbus-1.0 /usr/lib/x86_64-linux-gnu/dbus-1.0/include" >> "qtbase/src/tools/bootstrap-dbus/bootstrap-dbus.pro"
echo "INCLUDEPATH *= /usr/include/dbus-1.0 /usr/lib/x86_64-linux-gnu/dbus-1.0/include" >> "qtbase/src/tools/qdbuscpp2xml/qdbuscpp2xml.pro"
echo "INCLUDEPATH *= /usr/include/dbus-1.0 /usr/lib/x86_64-linux-gnu/dbus-1.0/include" >> "qtbase/src/tools/qdbusxml2cpp/qdbusxml2cpp.pro"

# fix xcb / x11 test / build
echo "LIBS *= -lXau -lXdmcp" >> "qtbase/config.tests/qpa/xcb/xcb.pro"
echo "LIBS *= -lXau -lXdmcp" >> "qtbase/config.tests/qpa/xcb-xkb/xcb-xkb.pro"

./configure \
-prefix "${CROSS_DEVICE_OPTWARES_PATH}/../Qt/${QT_VERSION}" \
-opensource \
-confirm-license \
-platform linux-g++-64 \
-arch arm \
-xplatform "${CROSS_DEVICE_MKSPEC}" \
-no-c++11 \
-no-pkg-config \
-nomake examples \
-nomake demos \
-make tools \
-no-pch \
-qt-xkbcommon \
-qt-xcb \
-qpa xcb \
-opengl es2 \
&& make -j ${CROSS_MAKE_JOBS} \
&& make -j ${CROSS_MAKE_JOBS} install

cd "${CUR_PWD}"
