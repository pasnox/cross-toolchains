#!/bin/bash

. ../optwares/build-constants.sh

# Create openpandora sdk for crossbuild use.

# Give absolute filepath to avoid some possible errors
OPENPANDORA_IMAGE="/dev/sde2"
OPENPANDORA_ROOT_FS="/mnt"
OPENPANDORA_SDK_FS="${CROSS_DEVICE_SDK_PATH}"

# OpenPandora content to copy / delete
# Directories
INCLUDES_LIST="usr/include usr/X11/include usr/X11R6/include usr/openwin/include"
LIBS_LIST="lib usr/lib usr/X11/lib usr/X11R6/lib usr/openwin/lib opt/vc"
PKG_CONFIG_LIST="usr/lib/pkgconfig usr/lib/arm-linux-gnueabihf/pkgconfig usr/share/pkgconfig"
# Files
CONFIG_BINARIES_LIST="usr/bin/*-config"
BAD_FILES_LIST="usr/include/features.h usr/bin/apt-config usr/bin/pkg-config usr/bin/raspi-config"
LD_SCRIPTS_LIST="usr/lib/arm-linux-gnueabihf/libc.so usr/lib/arm-linux-gnueabihf/libpthread.so"

# $1 = filepath to patch
# $2 = prefix
# $3 = 1 => make executable, 0 => do nothing
function patchPrefix()
{
    if [ ! -f "$1" ]; then
        return
    fi
    
    # Do not process symbolic links
    if [ -L "$1" ]; then
        return
    fi
    
    # Prepend new prefix to prefix
    prefix="$2"
    
    if [ ! "${prefix:0:1}" = "/" ]; then
        prefix="$PWD/$2"
    fi
    
    # Set prefix to /usr for empty prefix
    sed -e 's#^prefix=$#prefix=/usr#1' "$1" > "$1".new
    mv "$1".new "$1"
    
    sed -e "s#^prefix=/usr#prefix=\"$prefix\"/usr#1" "$1" > "$1".new
    mv "$1".new "$1"
    
    sed -e "s#^prefix=/lib#prefix=\"$prefix\"/lib#1" "$1" > "$1".new
    mv "$1".new "$1"
    
    sed -e "s#^exec_prefix=/usr#exec_prefix=\"$prefix\"/usr#1" "$1" > "$1".new
    mv "$1".new "$1"
    
    sed -e "s#^exec_prefix=/lib#exec_prefix=\"$prefix\"/lib#1" "$1" > "$1".new
    mv "$1".new "$1"
    
    sed -e "s#^includedir=/usr#includedir=\"$prefix\"/usr#1" "$1" > "$1".new
    mv "$1".new "$1"
    
    sed -e "s#^includedir=/lib#includedir=\"$prefix\"/lib#1" "$1" > "$1".new
    mv "$1".new "$1"
    
    sed -e "s#^libdir=/usr#libdir=\"$prefix\"/usr#1" "$1" > "$1".new
    mv "$1".new "$1"
    
    sed -e "s#^libdir=/lib#libdir=\"$prefix\"/lib#1" "$1" > "$1".new
    mv "$1".new "$1"
    
    sed -e "s#-L/usr#-L\"$prefix\"/usr#g" "$1" > "$1".new
    mv "$1".new "$1"
    
    sed -e "s#-L/lib#-L\"$prefix\"/lib#g" "$1" > "$1".new
    mv "$1".new "$1"
    
    sed -e "s#-I/usr#-I\"$prefix\"/usr#g" "$1" > "$1".new
    mv "$1".new "$1"
    
    sed -e "s#-I/lib#-I\"$prefix\"/lib#g" "$1" > "$1".new
    mv "$1".new "$1"
    
    if [ "$3" = "1" ]; then
        chmod +x "$1"
    fi
}

# $1 = filepath to patch
# $2 = prefix
function fixRoot()
{
    if [ ! -f "$1" ]; then
        return
    fi
    
    prefix="$2"
    
    if [ ! "${prefix:0:1}" = "/" ]; then
        prefix="$PWD/$2"
    fi
    
    sed -e "s# /usr/lib/# $prefix/usr/lib/#g" "$1" > "$1".new
    mv "$1".new "$1"

    sed -e "s# /lib/# $prefix/lib/#g" "$1" > "$1".new
    mv "$1".new "$1"
}

# $1 = filepath to delete
function remove()
{
    if [ -f "$1" ]; then
        echo "+ Removing \"$1\"..."
        rm "$1"
    fi
}

# $1 absolute file path of symlink to resolve
function resolveSymlink()
{
    target="`readlink -n "$1"`"
    
    if [ ! ${target:0:1} = "/" ]; then
        target="`dirname \"$1\"`/$target"
    elif [ ! ${target:0:${#OPENPANDORA_SDK_FS}} = "$OPENPANDORA_SDK_FS" ]; then
        target="$OPENPANDORA_SDK_FS$target"
    fi
    
    if [ -L "$target" ]; then
        target=`resolveSymlink "$target"`
    fi
    
    echo "`realpath -s \"$target\"`"
}

# $1 folder where to check
function fixSymlinksRecursively()
{
    for name in "$1"/* ; do
        if [ -d "$name" ]; then
            fixSymlinksRecursively "$name"
        elif [ -L "$name" ]; then
            source="`realpath -s \"$name\"`"
            target=`resolveSymlink "$source"`
            
            if [ "$source" = "$target" ]; then
                continue;
            fi
            
            if [ -f "$target" ]; then
                rm "$source"
                ln -s "$target" "$source"
            else
                echo "Can't resolve $source ($target)"
            fi
        fi
    done
}

function mountOpenPandora()
{
    sudo mount "$OPENPANDORA_IMAGE" "$OPENPANDORA_ROOT_FS"
}

function umountOpenPandora()
{
    sudo umount "$OPENPANDORA_IMAGE"
}

sudo echo

mountOpenPandora

# Copy files
for source in $INCLUDES_LIST $LIBS_LIST $PKG_CONFIG_LIST "$OPENPANDORA_ROOT_FS/"$CONFIG_BINARIES_LIST ; do
    if [ -d "$OPENPANDORA_ROOT_FS/$source" ]; then
        source="$OPENPANDORA_ROOT_FS/$source"
    fi
    
    if [ ! -d "$source" ] && [ ! -f "$source" ]; then
        echo " - Skip unexisting \"$source\"..."
        continue
    fi
    
    target="$OPENPANDORA_SDK_FS/${source/$OPENPANDORA_ROOT_FS\//}"
    
    if [ -f "$source" ]; then
        target=`dirname "$target"`
    fi
    
    mkdir -p "$target"
    
    if [ -d "$source" ]; then
        target=`dirname "$target"`
    fi
    
    echo "+ Syncing \"$source\" to \"$target\"..."
    rsync -aE "$source" "$target"
done

# Delete files
for source in $BAD_FILES_LIST ; do
    remove "$OPENPANDORA_SDK_FS/$source"
done

# Patch config files
for source in "$OPENPANDORA_SDK_FS/"$CONFIG_BINARIES_LIST ; do
    patchPrefix "$source" "$OPENPANDORA_SDK_FS" "1"
done

# Copy files
for source in $PKG_CONFIG_LIST ; do
    if [ -d "$OPENPANDORA_SDK_FS/$source" ]; then
        for file in "$OPENPANDORA_SDK_FS/$source"/*.pc ; do
            patchPrefix "$file" "$OPENPANDORA_SDK_FS"
        done
    fi
done

# Patch ld scripts
for source in $LD_SCRIPTS_LIST ; do
    fixRoot "$OPENPANDORA_SDK_FS/$source" "$OPENPANDORA_SDK_FS"
done

fixSymlinksRecursively "$OPENPANDORA_SDK_FS"

umountOpenPandora
