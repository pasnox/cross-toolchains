#!/bin/bash

TMP_DIR="${1}"
CUR_PWD="${PWD}"

if [ -z "$TMP_DIR" ]; then
    TMP_DIR="${PWD}/open-pandora-toolchain"
fi

if [ ! -d "$TMP_DIR" ]; then
    mkdir -p "$TMP_DIR"
fi

cd "$TMP_DIR"
cp -f "${CUR_PWD}/open-pandora-1.18.0.conf" .config
ct-ng build
cd "${CUR_PWD}"
