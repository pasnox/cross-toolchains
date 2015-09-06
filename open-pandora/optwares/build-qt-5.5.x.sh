#!/bin/bash

# $1: Message
# $2: Exit code
function die() {
    fusermount -u "${CROSS_DEVICE_SDK_PATH}"
    echo ${1}
    exit ${2}
}

# Fixes
# - https://bugreports.qt.io/secure/attachment/28991/qt-26817-fix.patch

SCRIPT_PWD=`dirname "${0}"`
QT_SRC_PATH=${1}
CROSS_DEVICE_MKSPEC="linux-open-pandora-g++"
DEVICE_IP=192.168.1.29
DEVICE_USER=pasnox
TMP_PWD=${HOME}/tmp

. ${SCRIPT_PWD}/build-constants.sh no-export || die "Can't source constants" 1

if [ ! -d "${QT_SRC_PATH}" ]; then
    die "Please give the Qt sources folder to build as first parameter." 2
fi

cd "${TMP_PWD}"
QT_SRC_VERSION=`${QT_SRC_PATH}/configure --help | grep -P -o 'Qt-([\d\.]+)' | cut -d '-' -f 2`
TMP_QT_PWD=${TMP_PWD}/Qt/OP/${QT_SRC_VERSION}

if [ ! -d "${CROSS_DEVICE_SDK_PATH}" ]; then
    mkdir -p "${CROSS_DEVICE_SDK_PATH}" || die "Can't create dir for sdk" 3
fi

if [ ! -d "${CROSS_DEVICE_OPTWARES_PATH}" ]; then
    mkdir -p "${CROSS_DEVICE_OPTWARES_PATH}" || die "Can't create dir for optwares" 4
fi

if [ ! -d "${TMP_QT_PWD}" ]; then
    mkdir -p "${TMP_QT_PWD}"|| die "Can't create dir for tmp" 5
fi

sshfs ${DEVICE_USER}@${DEVICE_IP}:// "${CROSS_DEVICE_SDK_PATH}" -o follow_symlinks || die "Can't mount sysroot" 6

cd "${TMP_QT_PWD}"

${QT_SRC_PATH}/configure \
    -I ${CROSS_DEVICE_OPTWARES_PATH}/include \
    -L ${CROSS_DEVICE_OPTWARES_PATH}/lib \
    -accessibility \
    -confirm-license \
    -dbus-linked \
    -debug \
    -device "${CROSS_DEVICE_MKSPEC}" \
    -device-option CROSS_COMPILE="${CROSS_DEVICE_TOOLCHAIN_BIN_PREFIX_PATH}" \
    -fontconfig \
    -make libs \
    -make tools \
    -no-c++11 \
    -no-icu \
    -no-pch \
    -nomake examples \
    -nomake tests \
    -opengl es2 \
    -opensource \
    -openssl-linked \
    -optimized-qmake \
    -prefix "${CROSS_DEVICE_OPTWARES_PATH}" \
    -qreal float \
    -qt-pcre \
    -qt-xcb \
    -qt-xkbcommon-x11 \
    -release \
    -sysroot "${CROSS_DEVICE_SDK_PATH}" \
    -system-freetype \
    -system-harfbuzz \
    -system-libpng \
    -system-libjpeg \
    -system-proxies \
    -system-sqlite \
    -system-zlib \
    -debug \
    -v \
    || die "Can't configure" 7

make -j ${CROSS_MAKE_JOBS} -i || die "Can't make" 8
make -j ${CROSS_MAKE_JOBS} install || die "Can't make install" 9

die "All done" 0

./configure \
-qpa xcb \
-reduce-exports \
-reduce-relocations \

# ------------------------

pasnox@pasnox-desktop:~/tmp$ /opt/Qt/5.5/Src/configure --help
+ cd qtbase
+ /opt/Qt/5.5/Src/qtbase/configure -top-level --help
Usage:  configure [options]

Installation options:

 These are optional, but you may specify install directories.

    -prefix <dir> ...... The deployment directory, as seen on the target device.
                         (default /usr/local/Qt-5.5.0, $PWD if -developer-build is active)

    -extprefix <dir> ... The installation directory, as seen on the host machine.
                         (default SYSROOT/PREFIX)

    -hostprefix [dir] .. The installation directory for build tools running on the
                         host machine. If [dir] is not given, the current build
                         directory will be used. (default EXTPREFIX)

 You may use these to change the layout of the install. Note that all directories
 except -sysconfdir should be located under -prefix/-hostprefix:

    -bindir <dir> ......... User executables will be installed to <dir>
                            (default PREFIX/bin)
    -headerdir <dir> ...... Headers will be installed to <dir>
                            (default PREFIX/include)
    -libdir <dir> ......... Libraries will be installed to <dir>
                            (default PREFIX/lib)
    -archdatadir <dir> .... Arch-dependent data used by Qt will be installed to <dir>
                            (default PREFIX)
    -plugindir <dir> ...... Plugins will be installed to <dir>
                            (default ARCHDATADIR/plugins)
    -libexecdir <dir> ..... Program executables will be installed to <dir>
                            (default ARCHDATADIR/libexec, ARCHDATADIR/bin for MinGW)
    -importdir <dir> ...... Imports for QML1 will be installed to <dir>
                            (default ARCHDATADIR/imports)
    -qmldir <dir> ......... Imports for QML2 will be installed to <dir>
                            (default ARCHDATADIR/qml)
    -datadir <dir> ........ Arch-independent data used by Qt will be installed to <dir>
                            (default PREFIX)
    -docdir <dir> ......... Documentation will be installed to <dir>
                            (default DATADIR/doc)
    -translationdir <dir> . Translations of Qt programs will be installed to <dir>
                            (default DATADIR/translations)
    -sysconfdir <dir> ..... Settings used by Qt programs will be looked for in <dir>
                            (default PREFIX/etc/xdg)
    -examplesdir <dir> .... Examples will be installed to <dir>
                            (default PREFIX/examples)
    -testsdir <dir> ....... Tests will be installed to <dir>
                            (default PREFIX/tests)

    -hostbindir <dir> .. Host executables will be installed to <dir>
                         (default HOSTPREFIX/bin)
    -hostlibdir <dir> .. Host libraries will be installed to <dir>
                         (default HOSTPREFIX/lib)
    -hostdatadir <dir> . Data used by qmake will be installed to <dir>
                         (default HOSTPREFIX)

Configure options:

 The defaults (*) are usually acceptable. A plus (+) denotes a default value
 that needs to be evaluated. If the evaluation succeeds, the feature is
 included. Here is a short explanation of each option:

 *  -release ........... Compile and link Qt with debugging turned off.
    -debug ............. Compile and link Qt with debugging turned on.
    -debug-and-release . Compile and link two versions of Qt, with and without
                         debugging turned on (Mac only).

    -force-debug-info .. Create symbol files for release builds.

    -developer-build ... Compile and link Qt with Qt developer options (including auto-tests exporting)

    -opensource ........ Compile and link the Open-Source Edition of Qt.
    -commercial ........ Compile and link the Commercial Edition of Qt.

    -confirm-license ... Automatically acknowledge the license (use with
                         either -opensource or -commercial)

    -no-c++11 .......... Do not compile Qt with C++11 support enabled.
 +  -c++11 ............. Compile Qt with C++11 support enabled.

 *  -shared ............ Create and use shared Qt libraries.
    -static ............ Create and use static Qt libraries.

    -no-largefile ...... Disables large file support.
 +  -largefile ......... Enables Qt to access files larger than 4 GB.

    -no-accessibility .. Do not compile Accessibility support.
                         Disabling accessibility is not recommended, as it will break QStyle
                         and may break other internal parts of Qt.
                         With this switch you create a source incompatible version of Qt,
                         which is unsupported.
 +  -accessibility ..... Compile Accessibility support.

    -no-sql-<driver> ... Disable SQL <driver> entirely.
    -qt-sql-<driver> ... Enable a SQL <driver> in the Qt SQL module, by default
                         none are turned on.
    -plugin-sql-<driver> Enable SQL <driver> as a plugin to be linked to
                         at run time.

                         Possible values for <driver>:
                         [ db2 ibase mysql oci odbc psql sqlite sqlite2 tds ]

    -system-sqlite ..... Use sqlite from the operating system.

    -no-qml-debug ...... Do not build the in-process QML debugging support.
 +  -qml-debug ......... Build the QML debugging support.

    -platform target ... The operating system and compiler you are building
                         on (default detected from host system).

                         See the README file for a list of supported
                         operating systems and compilers.

    -no-sse2 ........... Do not compile with use of SSE2 instructions.
    -no-sse3 ........... Do not compile with use of SSE3 instructions.
    -no-ssse3 .......... Do not compile with use of SSSE3 instructions.
    -no-sse4.1 ......... Do not compile with use of SSE4.1 instructions.
    -no-sse4.2 ......... Do not compile with use of SSE4.2 instructions.
    -no-avx ............ Do not compile with use of AVX instructions.
    -no-avx2 ........... Do not compile with use of AVX2 instructions.
    -no-mips_dsp ....... Do not compile with use of MIPS DSP instructions.
    -no-mips_dspr2 ..... Do not compile with use of MIPS DSP rev2 instructions.

    -qtnamespace <name>  Wraps all Qt library code in 'namespace <name> {...}'.
    -qtlibinfix <infix>  Renames all libQt*.so to libQt*<infix>.so.

    -testcocoon ........ Instrument Qt with the TestCocoon code coverage tool.
    -gcov .............. Instrument Qt with the GCov code coverage tool.

    -D <string> ........ Add an explicit define to the preprocessor.
    -I <string> ........ Add an explicit include path.
    -L <string> ........ Add an explicit library path.

 +  -pkg-config ........ Use pkg-config to detect include and library paths. By default,
                         configure determines whether to use pkg-config or not with
                         some heuristics such as checking the environment variables.
    -no-pkg-config ..... Disable use of pkg-config.
    -force-pkg-config .. Force usage of pkg-config (skips pkg-config usability
                         detection heuristic).

    -help, -h .......... Display this information.

Third Party Libraries:

    -qt-zlib ............ Use the zlib bundled with Qt.
 +  -system-zlib ........ Use zlib from the operating system.
                          See http://www.gzip.org/zlib

    -no-mtdev ........... Do not compile mtdev support.
 +  -mtdev .............. Enable mtdev support.

 +  -no-journald ........ Do not send logging output to journald.
    -journald ........... Send logging output to journald.

    -no-gif ............. Do not compile GIF reading support.

    -no-libpng .......... Do not compile PNG support.
    -qt-libpng .......... Use the libpng bundled with Qt.
 +  -system-libpng ...... Use libpng from the operating system.
                          See http://www.libpng.org/pub/png

    -no-libjpeg ......... Do not compile JPEG support.
    -qt-libjpeg ......... Use the libjpeg bundled with Qt.
 +  -system-libjpeg ..... Use libjpeg from the operating system.
                          See http://www.ijg.org

    -no-freetype ........ Do not compile in Freetype2 support.
    -qt-freetype ........ Use the libfreetype bundled with Qt.
 +  -system-freetype..... Use the libfreetype provided by the system (enabled if -fontconfig is active).
                          See http://www.freetype.org

    -no-harfbuzz ........ Do not compile HarfBuzz-NG support.
 *  -qt-harfbuzz ........ Use HarfBuzz-NG bundled with Qt to do text shaping.
                          It can still be disabled by setting
                          the QT_HARFBUZZ environment variable to "old".
    -system-harfbuzz .... Use HarfBuzz-NG from the operating system
                          to do text shaping. It can still be disabled
                          by setting the QT_HARFBUZZ environment variable to "old".
                          See http://www.harfbuzz.org

    -no-openssl ......... Do not compile support for OpenSSL.
 +  -openssl ............ Enable run-time OpenSSL support.
    -openssl-linked ..... Enabled linked OpenSSL support.

    -no-libproxy ....... Do not compile support for libproxy
 +  -libproxy .......... Use libproxy from the operating system.

    -qt-pcre ............ Use the PCRE library bundled with Qt.
 +  -system-pcre ........ Use the PCRE library from the operating system.

    -qt-xcb ............. Use xcb- libraries bundled with Qt.
                          (libxcb.so will still be used from operating system).
 +  -system-xcb ......... Use xcb- libraries from the operating system.

    -xkb-config-root .... Set default XKB config root. This option is used only together with -qt-xkbcommon-x11.
    -qt-xkbcommon-x11 ... Use the xkbcommon library bundled with Qt in combination with xcb.
 +  -system-xkbcommon-x11 Use the xkbcommon library from the operating system in combination with xcb.

    -no-xkbcommon-evdev . Do not use X-less xkbcommon when compiling libinput support.
 *  -xkbcommon-evdev .... Use X-less xkbcommon when compiling libinput support.

    -no-xinput2 ......... Do not compile XInput2 support.
 *  -xinput2 ............ Compile XInput2 support.

    -no-xcb-xlib......... Do not compile Xcb-Xlib support.
 *  -xcb-xlib............ Compile Xcb-Xlib support.

    -no-glib ............ Do not compile Glib support.
 +  -glib ............... Compile Glib support.

    -no-pulseaudio ...... Do not compile PulseAudio support.
 +  -pulseaudio ......... Compile PulseAudio support.

    -no-alsa ............ Do not compile ALSA support.
 +  -alsa ............... Compile ALSA support.

    -no-gtkstyle ........ Do not compile GTK theme support.
 +  -gtkstyle ........... Compile GTK theme support.

Additional options:

    -make <part> ....... Add part to the list of parts to be built at make time.
                         (defaults to: libs tools examples)
    -nomake <part> ..... Exclude part from the list of parts to be built.

    -skip <module> ..... Exclude an entire module from the build.

    -no-compile-examples ... Install only the sources of examples.

    -no-gui ............ Don't build the Qt GUI module and dependencies.
 +  -gui ............... Build the Qt GUI module and dependencies.

    -no-widgets ........ Don't build the Qt Widgets module and dependencies.
 +  -widgets ........... Build the Qt Widgets module and dependencies.

    -R <string> ........ Add an explicit runtime library path to the Qt
                         libraries.
    -l <string> ........ Add an explicit library.

    -no-rpath .......... Do not use the library install path as a runtime
                         library path.
 +  -rpath ............. Link Qt libraries and executables using the library
                         install path as a runtime library path. Equivalent
                         to -R install_libpath

    -continue .......... Continue as far as possible if an error occurs.

    -verbose, -v ....... Print verbose information about each step of the
                         configure process.

    -silent ............ Reduce the build output so that warnings and errors
                         can be seen more easily.

 *  -no-optimized-qmake ... Do not build qmake optimized.
    -optimized-qmake ...... Build qmake optimized.

    -no-nis ............ Do not compile NIS support.
 *  -nis ............... Compile NIS support.

    -no-cups ........... Do not compile CUPS support.
 *  -cups .............. Compile CUPS support.
                         Requires cups/cups.h and libcups.so.2.

    -no-iconv .......... Do not compile support for iconv(3).
 *  -iconv ............. Compile support for iconv(3).

    -no-evdev .......... Do not compile support for evdev.
 *  -evdev ............. Compile support for evdev.

    -no-tslib .......... Do not compile support for tslib.
 *  -tslib ............. Compile support for tslib.

    -no-icu ............ Do not compile support for ICU libraries.
 +  -icu ............... Compile support for ICU libraries.

    -no-fontconfig ..... Do not compile FontConfig support.
 +  -fontconfig ........ Compile FontConfig support.

    -no-strip .......... Do not strip binaries and libraries of unneeded symbols.
 *  -strip ............. Strip binaries and libraries of unneeded symbols when installing.

 *  -no-pch ............ Do not use precompiled header support.
    -pch ............... Use precompiled header support.

    -no-dbus ........... Do not compile the Qt D-Bus module.
 +  -dbus .............. Compile the Qt D-Bus module and dynamically load libdbus-1.
    -dbus-linked ....... Compile the Qt D-Bus module and link to libdbus-1.

    -reduce-relocations ..... Reduce relocations in the libraries through extra
                              linker optimizations (Qt/X11 and Qt for Embedded Linux only;
                              experimental; needs GNU ld >= 2.18).

    -no-use-gold-linker ..... Do not link using the GNU gold linker.
 +  -use-gold-linker ........ Link using the GNU gold linker if available.

    -force-asserts ........ Force Q_ASSERT to be enabled even in release builds.

    -sanitize [address|thread|memory|undefined] Enables the specified compiler sanitizer.

    -device <name> ............... Cross-compile for device <name> (experimental)
    -device-option <key=value> ... Add device specific options for the device mkspec
                                   (experimental)

 *  -no-separate-debug-info . Do not store debug information in a separate file.
    -separate-debug-info .... Strip debug information into a separate file.

    -no-xcb ............ Do not compile Xcb (X protocol C-language Binding) support.
 *  -xcb ............... Compile Xcb support.

    -no-eglfs .......... Do not compile EGLFS (EGL Full Screen/Single Surface) support.
 *  -eglfs ............. Compile EGLFS support.

    -no-directfb ....... Do not compile DirectFB support.
 *  -directfb .......... Compile DirectFB support.

    -no-linuxfb ........ Do not compile Linux Framebuffer support.
 *  -linuxfb ........... Compile Linux Framebuffer support.

    -no-kms ............ Do not compile KMS support.
 *  -kms ............... Compile KMS support (Requires EGL).

    -qpa <name> ......... Sets the default QPA platform (e.g xcb, cocoa, windows).

    -xplatform target ... The target platform when cross-compiling.

    -sysroot <dir> ...... Sets <dir> as the target compiler's and qmake's sysroot and also sets pkg-config paths.
    -no-gcc-sysroot ..... When using -sysroot, it disables the passing of --sysroot to the compiler

    -no-feature-<feature> Do not compile in <feature>.
    -feature-<feature> .. Compile in <feature>. The available features
                          are described in src/corelib/global/qfeatures.txt

    -qconfig local ...... Use src/corelib/global/qconfig-local.h rather than the
                          default (full).

    -qreal [double|float] typedef qreal to the specified type. The default is double.
                          Note that changing this flag affects binary compatibility.

    -no-opengl .......... Do not support OpenGL.
    -opengl <api> ....... Enable OpenGL support
                          With no parameter, this will attempt to auto-detect
                          OpenGL ES 2.0 and higher, or regular desktop OpenGL.
                          Use es2 for <api> to override auto-detection.

    -no-libinput ........ Do not support libinput.
 *  -libinput ........... Enable libinput support.

    -no-gstreamer ....... Do not support GStreamer.
 +  -gstreamer <version>  Enable GStreamer support
                          With no parameter, this will attempt to auto-detect GStreamer 0.10 and
                          1.0. GStreamer 0.10 is used by default when available.
                          Use 0.10 or 1.0 for <version> to override auto-detection.

 *  -no-system-proxies .. Do not use system network proxies by default.
    -system-proxies ..... Use system network proxies by default.

    -no-warnings-are-errors Make warnings be treated normally
    -warnings-are-errors  Make warnings be treated as errors
                          (enabled if -developer-build is active)

QNX/Blackberry options:

    -no-slog2 .......... Do not compile with slog2 support.
    -slog2 ............. Compile with slog2 support.

    -no-pps ............ Do not compile with pps support.
    -pps ............... Compile with pps support.

    -no-imf ............ Do not compile with imf support.
    -imf ............... Compile with imf support.

    -no-lgmon .......... Do not compile with lgmon support.
    -lgmon ............. Compile with lgmon support.

MacOS/iOS options:

    -Fstring ........... Add an explicit framework path.
    -fw string ......... Add an explicit framework.

 *  -framework ......... Build Qt as a series of frameworks and
                         link tools against those frameworks.
    -no-framework ...... Do not build Qt as a series of frameworks.

    -secure-transport .. Use SecureTransport instead of OpenSSL (requires -no-openssl)

    -sdk <sdk> ......... Build Qt using Apple provided SDK <sdk>. The argument should be
                         one of the available SDKs as listed by 'xcodebuild -showsdks'.
                         Note that the argument applies only to Qt libraries and applications built
                         using the target mkspec - not host tools such as qmake, moc, rcc, etc.

Android options:

    -android-sdk path .............. The Android SDK root path.
                                     (default $ANDROID_SDK_ROOT)

    -android-ndk path .............. The Android NDK root path.
                                     (default $ANDROID_NDK_ROOT)

    -android-ndk-platform .......... Sets the android platform
                                     (default android-9)

    -android-ndk-host .............. Sets the android NDK host (linux-x86, linux-x86_64, etc.)
                                     (default $ANDROID_NDK_HOST)

    -android-arch .................. Sets the android architecture (armeabi, armeabi-v7a, x86, mips,
                                     arm64-v8a, x86_64, mips64)
                                     (default armeabi-v7a)

    -android-toolchain-version ..... Sets the android toolchain version
                                     (default 4.9)

    -no-android-style-assets ....... Do not compile in the code which automatically extracts
                                     style assets from the run-time device. Setting this will
                                     make the Android style behave incorrectly, but will enable
                                     compatibility with the LGPL2.1 license.
 *  -android-style-assets .......... Compile the code which automatically extracts style assets
                                     from the run-time device. This option will make the
                                     Android platform plugin incompatible with the LGPL2.1.
