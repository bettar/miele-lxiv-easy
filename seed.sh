#!/bin/bash

# Alex Bettarini - 17 Mar 2019

#-------------------------------------------------------------------------------
# Once only, create symbolic links to patches to be reused

PATCH_FILE1a=openjpeg-2.2.0_miele-7.1.38.patch
PATCH_FILE1b=openjpeg-2.2.0_miele-7.3.46.patch

pushd patch

if [ ! -f ${PATCH_FILE1b} ]; then
    ln -s ${PATCH_FILE1a} ${PATCH_FILE1b}
fi

popd

#-------------------------------------------------------------------------------
export CONFIG_=CONFIG_
export KCONFIG_CONFIG=seed.conf
kconfig-mconf Kconfig-seed
