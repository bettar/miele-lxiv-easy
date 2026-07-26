#!/bin/bash

# Alex Bettarini - 15 Mar 2019

APP1=miele
APP=${APP1}-easy

# Check that kconfig-mconf is installed
which kconfig-mconf > /dev/null
if [ $? -ne 0 ]; then
    echo "Please install kconfig-mconf"
    exit 0
fi

# Check that cmake is installed
which cmake > /dev/null
if [ $? -ne 0 ]; then
    echo "Please install the command-line cmake"
    exit 0
fi

which sort > /dev/null
SORT=sort
if [ $? -ne 0 ]; then
SORT=gsort
fi

if [ ! -f seed.conf ]; then
    ./seed.sh

    if [ -f seed.conf ]; then
        echo "TIMESTAMP=$APP-$(date +%Y%m%d_%H%M)" >> seed.conf
    fi

    mkdir -p log
    exit 0
fi

source steps.conf
source seed.conf
source $CONFIG_VERSION_SET

if [ $CONFIG_GENERATOR_XC ] ; then
    GENERATOR="Xcode"
elif [ $CONFIG_GENERATOR_MK ] ; then
    GENERATOR="Unix Makefiles"
fi

DCMTK=dcmtk-$DCMTK_VERSION
GLEW=glew-$GLEW_VERSION
GLM=glm-$GLM_VERSION
ICONV=libiconv-$ICONV_VERSION
ITK=InsightToolkit-$ITK_VERSION
JASPER=jasper-$JASPER_VERSION
JPEG=jpeg-$JPEG_VERSION
MING=ming-$MING_VERSION
OPENJPG=openjpeg-$OPENJPG_VERSION
OPENSSL=openssl-$OPENSSL_VERSION
PNG=libpng-$PNG_VERSION
TIFF=tiff-$TIFF_VERSION
VTK=VTK-$VTK_VERSION
ZLIB=zlib-$ZLIB_VERSION
#XML2=libxml2-v$XML2_VERSION # 'v' in 2.9.13
XML2=libxml2-$XML2_VERSION
MIELE=$APP1-$MIELE_VERSION

if [ $CONFIG_SHARED_SOURCES ] ; then
    eval SRC=$CONFIG_SRC_DIR
else
    eval SRC=$CONFIG_SRC_DIR/$TIMESTAMP
fi
eval SRC_P=$CONFIG_SRC_DIR/$TIMESTAMP # patched packages cannot be shared with other projects

SRC_DCMTK=$SRC_P/$DCMTK  # patched
SRC_GLEW=$SRC/$GLEW
SRC_GLM=$SRC/$GLM
SRC_ICONV=$SRC/$ICONV
SRC_ITK=$SRC/$ITK
SRC_JASPER=$SRC/$JASPER
SRC_JPEG=$SRC/$JPEG
SRC_MING=$SRC/libming-$MING
SRC_OPENJPG=$SRC_P/$OPENJPG  # patched
SRC_OPENSSL=$SRC/$OPENSSL
SRC_PNG=$SRC/$PNG
SRC_TIFF=$SRC/$TIFF
SRC_VTK=$SRC/$VTK
SRC_XML2=$SRC/$XML2
SRC_ZLIB=$SRC/$ZLIB
SRC_APP=$SRC_P/$MIELE  # patched

eval BLD=$CONFIG_BLD_DIR/$TIMESTAMP
BLD_DCMTK=$BLD/$DCMTK
BLD_GLEW=$BLD/$GLEW
BLD_GLM=$BLD/$GLM
BLD_ICONV=$BLD/$ICONV
BLD_ITK=$BLD/$ITK
BLD_JASPER=$BLD/$JASPER
BLD_JPEG=$BLD/$JPEG
BLD_MING=$BLD/$MING
BLD_OPENJPG=$BLD/$OPENJPG
BLD_OPENSSL=$BLD/$OPENSSL
BLD_PNG=$BLD/$PNG
BLD_TIFF=$BLD/$TIFF
BLD_VTK=$BLD/$VTK
BLD_XML2=$BLD/$XML2
BLD_ZLIB=$BLD/$ZLIB

eval BIN=$CONFIG_BIN_DIR/$TIMESTAMP
BIN_DCMTK=$BIN/$DCMTK
BIN_GLEW=$BIN/$GLEW
BIN_GLM=$BIN/$GLM
BIN_ICONV=$BIN/$ICONV
BIN_ITK=$BIN/$ITK
BIN_JASPER=$BIN/$JASPER
BIN_JPEG=$BIN/$JPEG
BIN_MING=$BIN/$MING
BIN_OPENJPG=$BIN/$OPENJPG
BIN_OPENSSL=$BIN/$OPENSSL
BIN_PNG=$BIN/$PNG
BIN_TIFF=$BIN/$TIFF
BIN_VTK=$BIN/$VTK
BIN_XML2=$BIN/$XML2
BIN_ZLIB=$BIN/$ZLIB

echo "SRC: $SRC"
echo "BLD: $BLD"
echo "BIN: $BIN"

OSX_ARCHITECTURES=$(uname -m)
MAKE_FLAGS="-j $(sysctl -n hw.ncpu)"
GLEW_OPTIONS="-D BUILD_UTILS=ON -D BUILD_FRAMEWORK=OFF -D BUILD_SHARED_LIBS=OFF"
CMAKE=cmake
MIELE_HOME=$SRC/miele-lxiv-$MIELE_VERSION
EASY_HOME=$(pwd)
eval PATCH_DIR=$EASY_HOME/patch
mkdir -p $SRC
DCMTK_PAGE=dcmtk${DCMTK_MAJOR}${DCMTK_MINOR}${DCMTK_BUILD}
DEPL_TARG=$(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}')

#----------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_LIB_ICONV ] && [ ! -d $SRC_ICONV ] ; then
cd $SRC
curl -O https://ftp.gnu.org/gnu/libiconv/libiconv-1.18.tar.gz
tar -zxf $ICONV.tar.gz
rm $ICONV.tar.gz
fi

if [ $STEP_INFO_ICONV ] ; then
echo "=== iconv" ; cd $SRC_ICONV ; grep "_LIBICONV_VERSION" include/iconv.h.in
fi

if [ $STEP_CONFIGURE_LIB_ICONV ] ; then
mkdir -p $BLD_ICONV ; cd $BLD_ICONV
echo "=== Configure help"
$SRC_ICONV/configure --help
echo "=== Configure $ICONV, install to $BIN_ICONV"
$SRC_ICONV/configure --prefix=$BIN_ICONV --enable-static=yes --enable-shared=no --disable-rpath
fi

if [ $STEP_COMPILE_LIB_ICONV ] ; then
echo "=== Build $ICONV"
cd $BLD_ICONV
make clean
make $MAKE_FLAGS
echo "=== Install $ICONV"
make install
fi

#----------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_SOURCES_OPENSSL ] && [ ! -d $SRC_OPENSSL ] ; then
cd $SRC
# https://www.openssl.org/source/$OPENSSL.tar.gz
#curl -O https://dicom.offis.de/download/dcmtk/$DCMTK_PAGE/support/source/$OPENSSL.tar.gz
curl -o $OPENSSL.tar.gz -L "https://github.com/openssl/openssl/releases/download/$OPENSSL/$OPENSSL.tar.gz"
tar -zxf $OPENSSL.tar.gz
rm $OPENSSL.tar.gz
fi

if [ $STEP_CONFIGURE_LIB_OPENSSL ] ; then
echo "=== Configure $OPENSSL"
mkdir -p $BLD_OPENSSL ; cd $BLD_OPENSSL
$SRC_OPENSSL/config --prefix=$BIN_OPENSSL
fi

if [ $STEP_COMPILE_LIB_OPENSSL ] ; then
echo "=== Build $OPENSSL"
cd $BLD_OPENSSL
make $MAKE_FLAGS
make install
fi

#----------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_LIB_PNG ] && [ ! -d $SRC_PNG ]  ; then
cd $SRC
curl -O https://dicom.offis.de/download/dcmtk/$DCMTK_PAGE/support/source/$PNG.tar.gz
tar -zxf $PNG.tar.gz
rm $PNG.tar.gz
fi

if [ $STEP_INFO_PNG ] ; then
# Version in source files
cd $SRC_PNG
echo "=== PNG" ; grep -E "\(PNGLIB_(MAJOR|MINOR|RELEASE)" CMakeLists.txt
grep "define PNG_HEADER_VERSION_STRING" png.h
fi

if [ $STEP_CONFIGURE_LIB_PNG ] ; then
echo "=== Configure library $PNG"
mkdir -p $BLD_PNG ; cd $BLD_PNG
rm -f CMakeCache.txt
$CMAKE -G"$GENERATOR" \
    -D CMAKE_INSTALL_PREFIX=$BIN_PNG \
    -D CMAKE_OSX_ARCHITECTURES=$OSX_ARCHITECTURES \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_OSX_DEPLOYMENT_TARGET=$DEPL_TARG \
    -D PNG_FRAMEWORK=OFF \
    -D PNG_SHARED=OFF \
    $SRC_PNG
fi

if [ $STEP_COMPILE_LIB_PNG ] ; then
cd $BLD_PNG
echo "=== Build library PNG"
make $MAKE_FLAGS
echo "=== Install library PNG"
make install
fi

#----------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_LIB_Z ] && [ ! -d $SRC_ZLIB ] ; then
cd $SRC
wget https://zlib.net/$ZLIB.tar.gz
tar -xf $ZLIB.tar.gz
rm $ZLIB.tar.gz
fi

if [ $STEP_CONFIGURE_ZLIB ] ; then
echo -e "\n=== Configure library $ZLIB"
mkdir -p $BLD_ZLIB ; cd $BLD_ZLIB
rm -f CMakeCache.txt
$CMAKE -G"$GENERATOR" \
    -D CMAKE_INSTALL_PREFIX=$BIN_ZLIB \
    -D CMAKE_OSX_ARCHITECTURES=$OSX_ARCHITECTURES \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_OSX_DEPLOYMENT_TARGET=$DEPL_TARG \
    -D BUILD_SHARED_LIBS=ON \
    -D ZLIB_BUILD_EXAMPLES=ON \
    -D CMAKE_CXX_FLAGS="$COMPILER_FLAGS" \
    $SRC_ZLIB
fi

if [ $STEP_COMPILE_ZLIB ] ; then
cd $BLD_ZLIB
echo -e "\n=== Build library $ZLIB"
make $MAKE_FLAGS

echo -e "\n=== Install library $ZLIB"
make install
fi

#----------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_LIB_XML2 ] ; then
if [ -d $SRC_XML2 ] ; then
echo "=== Download $XML2 exists in $SRC_XML2"
else
cd $SRC
curl -O https://dicom.offis.de/download/dcmtk/$DCMTK_PAGE/support/source/$XML2.tar.xz
#https://dicom.offis.de/download/dcmtk/dcmtk370/support/source/libxml2-2.15.1.tar.xz
#https://dicom.offis.de/download/dcmtk/dcmtk370/support/source/libxml2-v2.15.1.tar.xz
tar -xf $XML2.tar.xz
rm $XML2.tar.xz
fi
fi

if [ $STEP_CONFIGURE_LIB_XML2 ] ; then
mkdir -p $BLD_XML2 ; cd $BLD_XML2
echo "=== Configure $XML2, install to $BIN_XML2"
rm -f CMakeCache.txt
$CMAKE -G"$GENERATOR" \
    -D CMAKE_INSTALL_PREFIX=$BIN_XML2 \
    -D CMAKE_OSX_ARCHITECTURES=$OSX_ARCHITECTURES \
    -D CMAKE_BUILD_TYPE=Release \
    -D BUILD_SHARED_LIBS=OFF \
    -D LIBXML2_WITH_ICONV=OFF \
    -D LIBXML2_WITH_TESTS=OFF \
    -D CMAKE_OSX_DEPLOYMENT_TARGET=$DEPL_TARG \
    $SRC_XML2
fi

if [ $STEP_COMPILE_LIB_XML2 ] ; then
echo "=== Build $ICONXML2V"
cd $BLD_XML2
make clean
make $MAKE_FLAGS

echo "=== Install $XML2"
make install
fi

#----------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_LIB_JPEG ] && [ ! -d $SRC_JPEG ] ; then
cd $SRC
curl -O http://www.ijg.org/files/jpegsrc.v$JPEG_VERSION.tar.gz
tar -zxf jpegsrc.v$JPEG_VERSION.tar.gz
rm jpegsrc.v$JPEG_VERSION.tar.gz
fi

if [ $STEP_INFO_JPEG ] ; then
cd $SRC_JPEG
echo -n "=== JPEG: " ;  grep "JVERSION" jversion.h | cut -d"\"" -f2
grep "define JPEG_LIB_VERSION" jpeglib.h
fi

if [ $STEP_CONFIGURE_LIB_JPEG ] ; then
echo "=== Configure LIBJPEG in $BLD_JPEG"
mkdir -p $BLD_JPEG ; cd $BLD_JPEG
$SRC_JPEG/configure \
		--prefix=$BIN_JPEG
fi

if [ $STEP_COMPILE_LIB_JPEG ] ; then
cd $BLD_JPEG
echo "=== Build LIBJPEG"
make $MAKE_FLAGS
echo "=== Install LIBJPEG"
make install
fi

#----------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_LIB_TIFF ] && [ ! -d $SRC_TIFF ] ; then
cd $SRC
wget http://download.osgeo.org/libtiff/$TIFF.tar.gz
tar -zxf $TIFF.tar.gz
rm $TIFF.tar.gz
fi

if [ $STEP_INFO_TIFF ] ; then
cd $SRC_TIFF
echo -n "=== TIFF: " ; grep "TIFFLIB_VERSION_STR" libtiff/tiffvers.h | cut -d"\"" -f2 | awk -F '\\\\n' '{print $1}'
fi

if [ $STEP_CONFIGURE_LIB_TIFF ] ; then
echo "=== Configure library $TIFF"
mkdir -p $BLD_TIFF ; cd $BLD_TIFF
rm -f CMakeCache.txt
$CMAKE -G"$GENERATOR" \
    -D CMAKE_INSTALL_PREFIX=$BIN_TIFF \
    -D CMAKE_OSX_ARCHITECTURES=$OSX_ARCHITECTURES \
    -D CMAKE_OSX_DEPLOYMENT_TARGET=$DEPL_TARG \
    -D BUILD_SHARED_LIBS=ON \
    -D tiff-docs=ON \
    -D tiff-tests=OFF \
    -D zlib=OFF \
    -D lzma=OFF \
    -D zstd=OFF \
    -D webp=OFF \
    -D ZLIB_INCLUDE_DIR=$BIN_ZLIB/include \
    -D ZLIB_LIBRARY_RELEASE=$BIN_ZLIB/lib/libz.a \
    -D JPEG_INCLUDE_DIR=$BIN_JPEG/include \
    -D JPEG_LIBRARY=$BIN_JPEG/lib/libjpeg.a \
    -D CMAKE_CXX_FLAGS="$COMPILER_FLAGS" \
    $SRC_TIFF
fi

if [ $STEP_COMPILE_LIB_TIFF ] ; then
echo "=== Build library $TIFF"
cd $BLD_TIFF
make $MAKE_FLAGS
echo "=== Install library $TIFF"
make install

#sed -i '' -e "s/typedef TIFF_UINT64_T/\/\/typedef TIFF_UINT64_T/g" "$BIN_TIFF/include/tiff.h"
#sed -i '' -e "s/uint64 tiff_diroff/TIFF_UINT64_T tiff_diroff/g" "$BIN_TIFF/include/tiff.h"
#sed -i '' -e "s/uint64/TIFF_UINT64_T/g" "$BIN_TIFF/include/tiffio.h"
fi

#-------------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_SOURCES_VTK ] && [ ! -d $SRC_VTK ] ; then
cd $SRC
# See https://github.com/Kitware/VTK/blob/master/Documentation/dev/git/download.md
#git clone git://vtk.org/VTK.git $VTK
#git clone https://github.com/Kitware/VTK.git $VTK

# Stable, see http://www.vtk.org/download/
#curl -O http://www.vtk.org/files/release/$VTK_MAJOR.$VTK_MINOR/VTK-$VTK_VERSION.tar.gz ; tar -zxf VTK-$VTK_VERSION.tar.gz
wget https://www.vtk.org/files/release/$VTK_MAJOR.$VTK_MINOR/$VTK.tar.gz
tar -zxf $VTK.tar.gz
rm $VTK.tar.gz
fi

if [ $STEP_INFO_VTK ] ; then
cd $SRC_VTK
echo "=== VTK: " ; grep "_VERSION" CMake/vtkVersion.cmake
echo -n "=== VTK_JPEG: " ; grep "JVERSION" ThirdParty/jpeg/vtkjpeg/jversion.h | cut -d"\"" -f2
grep "define JPEG_LIB_VERSION" ThirdParty/jpeg/vtkjpeg/jpeglib.h
echo -n "=== VTK_TIFF: " ; grep "TIFFLIB_VERSION_STR" ThirdParty/tiff/vtktiff/libtiff/tiffvers.h | cut -d"\"" -f2 | awk -F '\\\\n' '{print $1}'
fi

if [ $STEP_CONFIGURE_VTK ] ; then
echo "=== Configure VTK"
mkdir -p $BLD_VTK ; cd $BLD_VTK
rm -f CMakeCache.txt
$CMAKE -G"$GENERATOR" \
    -D CMAKE_INSTALL_PREFIX=$BIN_VTK \
    -D CMAKE_OSX_ARCHITECTURES=$OSX_ARCHITECTURES \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_OSX_DEPLOYMENT_TARGET=$DEPL_TARG \
    -D BUILD_SHARED_LIBS=OFF \
    -D BUILD_TESTING=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_DOCUMENTATION=OFF \
    -D VTK_LEGACY_REMOVE=OFF \
    $VTK_OPTIONS \
    -D VTK_MODULE_ENABLE_VTK_hdf5=NO \
    -D VTK_MODULE_ENABLE_VTK_tiff=YES \
    -D tiff_BINARY_DIR=$BIN_TIFF \
    -D tiff_SOURCE_DIR=$SRC_TIFF \
    -D CMAKE_CXX_FLAGS="$COMPILER_FLAGS" \
    $SRC_VTK
fi

if [ $STEP_COMPILE_VTK ] ; then
echo "=== Compile VTK"
cd $BLD_VTK
make $MAKE_FLAGS
echo "=== Install VTK"
make install

# TODO: get them into the install directory by enabling the appropriate modules
#cp $SRC_VTK/Rendering/VolumeOpenGL/vtkOpenGLVolumeTextureMapper3D.h $BIN_VTK/include/vtk-$VTK_MAJOR.$VTK_MINOR
#cp $SRC_VTK/Rendering/Volume/vtkVolumeTextureMapper.h $BIN_VTK/include/vtk-$VTK_MAJOR.$VTK_MINOR
#cp $SRC_VTK/Rendering/Volume/vtkVolumeTextureMapper2D.h $BIN_VTK/include/vtk-$VTK_MAJOR.$VTK_MINOR
#cp $SRC_VTK/Rendering/Volume/vtkVolumeTextureMapper3D.h $BIN_VTK/include/vtk-$VTK_MAJOR.$VTK_MINOR
#sed -i -e "s/#include \"vtkRenderingVolumeOpenGLModule.h\"/\/\/#include \"vtkRenderingVolumeOpenGLModule.h\"/g" "$BIN_VTK/include/vtk-$VTK_MAJOR.$VTK_MINOR/vtkVolumeTextureMapper3D.h"
fi

if [ $STEP_COLLAPSE_VTK ] ; then
cd $BIN_VTK
mkdir -p libC
VTK_COLLAPSED=libC/libVTK.a
if [ -f $VTK_COLLAPSED ] ; then
    rm $VTK_COLLAPSED
fi
echo "=== Collapse VTK into a single library"
ARGS=$(find lib -name '*.a' -type f)
libtool -static -v -o $VTK_COLLAPSED $ARGS
fi

#--------------------------------------
if [ $STEP_DOWNLOAD_MING ] ; then
if [ -d $SRC_MING ] ; then
echo "=== Download $MING exists"
else
echo "=== Download $MING"
cd $SRC
#git clone https://github.com/libming/libming.git
wget https://github.com/libming/libming/archive/$MING.tar.gz
tar -zxf $MING.tar.gz
rm $MING.tar.gz

# Patch
sed -i '' -e "s/newEmptySWFBlock();/newEmptySWFBlock(SWFBlocktype type);/g" "$SRC_MING/src/blocks/block.h"

# run once only, to create $SRC_MING/configure
cd $SRC_MING
sh autogen.sh
fi
fi

if [ $STEP_CONFIGURE_LIB_MING ] ; then
mkdir -p $BLD_MING ; cd $BLD_MING
echo -e "\n=== Configure help"
$SRC_MING/configure --help

echo -e "\n=== Configure $MING, install to $BIN_MING"
#export CFLAGS="-arch x86_64 -arch arm64"
$SRC_MING/configure \
    --enable-shared=no \
    --disable-freetype \
    --prefix=$BIN_MING
fi

if [ $STEP_COMPILE_LIB_MING ] ; then
echo -e "\n=== Build $MING"
cd $BLD_MING
make clean
make $MAKE_FLAGS

echo -e "\n=== Install $MING"
make install
fi

#--------------------------------------
if [ $STEP_DOWNLOAD_SOURCES_ITK ] && [ ! -d $SRC_ITK ] ; then
#mkdir -p $SRC/ITK ;
cd $SRC
# Latest
#git clone git://itk.org/ITK.git $ITK
# Latest stable release, see https://itk.org/Wiki/ITK/Source#Latest_Stable_Release
#git clone -b release https://itk.org/ITK.git $ITK
wget https://github.com/InsightSoftwareConsortium/ITK/releases/download/v$ITK_MAJOR.$ITK_MINOR.$ITK_BUILD/$ITK.tar.gz
tar -zxf $ITK.tar.gz
rm $ITK.tar.gz
fi

if [ $STEP_INFO_ITK ] ; then
cd $SRC_ITK 
echo "=== ITK" ; grep --include=*.txt "(ITK_VERSION" CMakeLists.txt
fi

if [ $STEP_CONFIGURE_ITK ] ; then
echo "=== Configure ITK"
mkdir -p $BLD_ITK ; cd $BLD_ITK
rm -f CMakeCache.txt
$CMAKE -G"$GENERATOR" \
    -D CMAKE_INSTALL_PREFIX=$BIN_ITK \
    -D CMAKE_OSX_ARCHITECTURES=$OSX_ARCHITECTURES \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_OSX_DEPLOYMENT_TARGET=$DEPL_TARG \
    -D BUILD_SHARED_LIBS=OFF \
    -D BUILD_TESTING=OFF \
    -D BUILD_EXAMPLES=OFF \
    -D Module_ITKOpenJPEG=OFF \
    -D Module_ITKVtkGlue=ON \
    -D VTK_DIR=$BIN_VTK/lib/cmake/vtk-$VTK_MAJOR.$VTK_MINOR \
    -D CMAKE_CXX_FLAGS="$COMPILER_FLAGS" \
    $SRC_ITK

fi

if [ $STEP_BUILD_ITK ] ; then
echo "=== Compile ITK"
cd $BLD_ITK
#make clean
make $MAKE_FLAGS
echo "=== Install ITK"
make install
fi

#echo "Verify before editing1" ; diffmerge.sh $HOME/$LXIV/glue/dcmtk/dcmnet/dimget.mm $SRC_DCMTK/dcmnet/libsrc/dimget.cc

if [ $STEP_COLLAPSE_ITK ] ; then
cd $BIN_ITK
mkdir -p libC
ITK_COLLAPSED=libC/libITK.a
if [ ! -f $ITK_COLLAPSED ] ; then
    echo "=== Collapse ITK into a single library"
    ARGS=$(find lib -name '*.a' -type f)
    libtool -static -v -o $ITK_COLLAPSED $ARGS
else
    echo "=== $ITK_COLLAPSED exists"
fi
fi

#-------------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_SOURCES_DCMTK ] && [ ! -d $SRC_DCMTK ] ; then
mkdir -p $SRC_DCMTK/.. ; cd $SRC_DCMTK/..
#curl -O "ftp://dicom.offis.de/pub/dicom/offis/software/dcmtk/$DCMTK_PAGE/$DCMTK.tar.gz"
wget "https://dicom.offis.de/download/dcmtk/$DCMTK_PAGE/$DCMTK.tar.gz"
tar -zxf $DCMTK.tar.gz
rm $DCMTK.tar.gz
fi

PATCH_FILENAME=${DCMTK}_${MIELE}.patch

#echo "PATCH_DIR:$PATCH_DIR, PATCH_FILENAME:$PATCH_FILENAME"
if [ $STEP_PATCH_DCMTK ] && [ -f $PATCH_DIR/$PATCH_FILENAME ] ; then
cd $SRC_DCMTK
echo "=== Patch DCMTK"
#patch --dry-run -p1 -i $PATCH_DIR/$PATCH_FILENAME
patch -p1 -i $PATCH_DIR/$PATCH_FILENAME
fi

if [ $STEP_INFO_DCMTK ] ; then   
cd $SRC_DCMTK
echo "=== DCMTK" ; grep "^PACKAGE_VERSION" config/configure
#git show head | grep commit ; git branch
fi

if [ $STEP_CONFIGURE_DCMTK ] ; then
#-------------------------------------------------------------------------------
DCMTK_OPTIONS="$DCMTK_OPTIONS -D DCMTK_WITH_OPENSSL=ON -D OPENSSL_VERSION_CHECK=ON -D OPENSSL_INCLUDE_DIR=$BIN_OPENSSL/include -D OPENSSL_SSL_LIBRARY=$BIN_OPENSSL/lib/libssl.a -D OPENSSL_CRYPTO_LIBRARY=$BIN_OPENSSL/lib/libcrypto.a"

DCMTK_OPTIONS="$DCMTK_OPTIONS -D DCMTK_WITH_PNG=OFF"

DCMTK_OPTIONS="$DCMTK_OPTIONS -D DCMTK_WITH_ICONV=OFF"

DCMTK_OPTIONS="$DCMTK_OPTIONS -D DCMTK_WITH_TIFF=ON -D TIFF_INCLUDE_DIR=$BIN_TIFF/include -D TIFF_LIBRARY_RELEASE=$BIN_TIFF/lib/libtiff.dylib"

DCMTK_OPTIONS="$DCMTK_OPTIONS -D DCMTK_WITH_OPENJPEG=ON -D OpenJPEG_DIR:PATH=$BIN_OPENJPG/lib/openjpeg-$OPENJPG_MAJOR.$OPENJPG_MINOR"

DCMTK_OPTIONS="$DCMTK_OPTIONS -D DCMTK_WITH_ZLIB=ON -D ZLIB_INCLUDE_DIR=$BIN_ZLIB/include -D ZLIB_LIBRARY_RELEASE=$BIN_ZLIB/lib/libz.a"

DCMTK_OPTIONS="$DCMTK_OPTIONS -D DCMTK_WITH_XML=ON -D LIBXML2_INCLUDE_DIR=$BIN_XML2/include/libxml2 -D LIBXML2_LIBRARY=$BIN_XML2/lib/libxml2.a -D LIBXML2_XMLLINT_EXECUTABLE=$BIN_XML2/bin/xmllint"
#-------------------------------------------------------------------------------
echo "=== Configure $DCMTK"
mkdir -p $BLD_DCMTK ; cd $BLD_DCMTK
rm -f CMakeCache.txt
$CMAKE -G"$GENERATOR" \
    -D CMAKE_INSTALL_PREFIX=$BIN_DCMTK \
    -D CMAKE_OSX_ARCHITECTURES=$OSX_ARCHITECTURES \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_OSX_DEPLOYMENT_TARGET=$DEPL_TARG \
    -D CMAKE_CXX_FLAGS="-D $DCMTK_CXX_FLAGS" \
    -D BUILD_SHARED_LIBS=OFF \
    $DCMTK_OPTIONS \
    -D JPEG_INCLUDE_DIR=$BIN_JPEG/include \
    -D JPEG_LIBRARY_RELEASE=$BIN_JPEG/lib/libjpeg.a \
    $SRC_DCMTK
fi

if [ $STEP_COMPILE_DCMTK ] ; then        
echo "=== Build DCMTK in: $BLD_DCMTK"
cd $BLD_DCMTK
CXXFLAGS="$COMPILER_FLAGS -D$DCMTK_CXX_FLAGS"
make clean
# If you get errors about _EVP_PKEY_get_bits, comment in the following 4 brew lines
#brew unlink openssl@3
#brew link openssl@1.1
make $MAKE_FLAGS
#brew unlink openssl@1.1
#brew link openssl@3
fi

if [ $STEP_INSTALL_DCMTK ] ; then        
echo "=== Install DCMTK in: $BIN_DCMTK"
cd $BLD_DCMTK
make install
fi

if [ $STEP_POST_INSTALL_DCMTK ] ; then        
echo "=== Post-install DCMTK"
cp -R $SRC_DCMTK/dcmjpeg/libijg8 $BIN_DCMTK/include/dcmtk/dcmjpeg
cp -R $SRC_DCMTK/dcmjpeg/libijg12 $BIN_DCMTK/include/dcmtk/dcmjpeg
cp -R $SRC_DCMTK/dcmjpeg/libijg16 $BIN_DCMTK/include/dcmtk/dcmjpeg
cp $SRC_DCMTK/dcmjpls/libcharls/intrface.h $BIN_DCMTK/include/dcmtk/dcmjpls
cp $SRC_DCMTK/dcmjpls/libcharls/pubtypes.h $BIN_DCMTK/include/dcmtk/dcmjpls
sed -i -e "s@#include \"config.h\"@//#include \"config.h\"@g" "$BIN_DCMTK/include/dcmtk/dcmjpls/pubtypes.h"
if [ $DCMTK_VERSION != 3.6.2 ] && [ $DCMTK_VERSION != 3.6.3 ] && [ $DCMTK_VERSION != 3.6.4 ] ; then
    sed -i -e "s/#define PACKAGE_DATE \"DEV\"/#define PACKAGE_DATE \"$(date +%Y%m%d)\"/g" "$BIN_DCMTK/include/dcmtk/config/osconfig.h"
fi
fi

if [ $STEP_COLLAPSE_DCMTK ] ; then
cd $BIN_DCMTK
mkdir -p libC
DCMTK_COLLAPSED=libC/libDCMTK.a
if [ -f $DCMTK_COLLAPSED ] ; then
    rm $DCMTK_COLLAPSED
fi
echo "=== Collapse DCMTK into a single library"
ARGS=$(find lib -name '*.a' -type f)
libtool -static -v -o $DCMTK_COLLAPSED $ARGS
fi

#-------------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_SOURCES_OPENJPG ] && [ ! -d $SRC_OPENJPG ] ; then
mkdir -p $SRC_OPENJPG/.. ; cd $SRC_OPENJPG/..

#git clone https://github.com/uclouvain/openjpeg.git $OPENJPG
#wget https://github.com/uclouvain/openjpeg/archive/$OPENJPG_TAR.tar.gz
wget https://github.com/uclouvain/openjpeg/archive/refs/tags/$OPENJPG_TAR.tar.gz

tar -zxf $OPENJPG_TAR.tar.gz
rm $OPENJPG_TAR.tar.gz
fi

PATCH_FILENAME=${OPENJPG}_${MIELE}.patch

if [ $STEP_PATCH_OPENJPG ] ; then
cd $SRC_OPENJPG
echo "=== Patch OpenJPEG"
if [ -f $PATCH_DIR/$PATCH_FILENAME ] ; then
#patch --dry-run -p1 -i $PATCH_DIR/$PATCH_FILENAME
patch -p1 -i $PATCH_DIR/$PATCH_FILENAME
fi
fi

if [ $STEP_INFO_OPENJPG ] ; then   
cd $SRC_OPENJPG
echo "=== OPENjpeg" ; grep "OPENJPEG_VERSION" CMakeLists.txt
fi

if [ $STEP_CONFIGURE_OPENJPG ] ; then
echo "=== Configure OpenJPEG: $BLD_OPENJPG"
mkdir -p $BLD_OPENJPG ; cd $BLD_OPENJPG
$CMAKE -G"$GENERATOR" \
    -D CMAKE_INSTALL_PREFIX=$BIN_OPENJPG \
    -D CMAKE_OSX_ARCHITECTURES=$OSX_ARCHITECTURES \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_OSX_DEPLOYMENT_TARGET=$DEPL_TARG \
    -D CMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -D BUILD_SHARED_LIBS=OFF \
    -D BUILD_THIRDPARTY=ON \
    -D CMAKE_CXX_FLAGS="$COMPILER_FLAGS" \
    $SRC_OPENJPG
fi

if [ $STEP_BUILD_OPENJPG ] ; then
echo "=== Compile OpenJPEG: $BLD_OPENJPG"
cd $BLD_OPENJPG
make clean
make $MAKE_FLAGS
fi

if [ $STEP_INSTALL_OPENJPG ] ; then
cd $BLD_OPENJPG
echo "=== Install OpenJPEG to: $BIN_OPENJPG"
make install
cp $SRC_OPENJPG/src/bin/common/format_defs.h $BIN_OPENJPG/include
fi

#-------------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_SOURCES_JASPER ] && [ ! -d $SRC_JASPER ] ; then
cd $SRC
wget https://github.com/jasper-software/jasper/releases/download/version-$JASPER_VERSION/$JASPER.tar.gz
tar -zxf $JASPER.tar.gz
rm $JASPER.tar.gz
fi

if [ $STEP_INFO_JASPER ] ; then   
echo "=== Jasper" ; cd $SRC_JASPER ; grep "JAS_VERSION" CMakeLists.txt
fi

if [ $STEP_CONFIGURE_JASPER ] ; then
echo "=== Configure Jasper"
mkdir -p $BLD_JASPER ; cd $BLD_JASPER
$CMAKE -G"$GENERATOR" \
    -D CMAKE_INSTALL_PREFIX=$BIN_JASPER \
    -D CMAKE_OSX_ARCHITECTURES=$OSX_ARCHITECTURES \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_OSX_DEPLOYMENT_TARGET=$DEPL_TARG \
    -D CMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -D CMAKE_CXX_FLAGS="$COMPILER_FLAGS" \
    -D JAS_ENABLE_AUTOMATIC_DEPENDENCIES=OFF \
    -D JAS_ENABLE_SHARED=OFF \
    -D JAS_ENABLE_PROGRAMS=OFF \
    $SRC_JASPER
fi

if [ $STEP_BUILD_JASPER ] ; then
echo "=== Compile Jasper"
cd $BLD_JASPER
make clean
make $MAKE_FLAGS
echo "=== Install Jasper"
make install
fi

#----------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_SOURCES_GLEW ] && [ ! -d $SRC_GLEW ] ; then
cd $SRC

if [ $GLEW_VERSION == "latest" ] ; then
    echo "Download GLEW latest"
    git clone https://github.com/nigels-com/glew.git $GLEW
else
    echo "Download GLEW stable"
    #wget https://sourceforge.net/projects/glew/files/glew/$GLEW_VERSION/$GLEW.tgz
    git clone --branch $GLEW --single-branch --depth 1 https://github.com/nigels-com/glew.git $GLEW

    echo "Edit line 13 of $SRC_GLEW/auto/Makefile from python to python3, then do"
    echo "cd $SRC_GLEW/auto"
    echo "make"
fi

cd $SRC_GLEW/auto
#ln -s /usr/local/bin/python3 /usr/local/bin/python
make
fi

if [ $STEP_INFO_GLEW ] ; then
echo "=== Info $GLEW"
echo "SRC_GLEW: $SRC_GLEW"
echo "BLD_GLEW: $BLD_GLEW"
echo "BIN_GLEW: $BIN_GLEW"
cd $SRC_GLEW
grep -w "VERSION" include/GL/glew.h
fi

if [ $STEP_CONFIGURE_GLEW ] ; then
echo "=== Configure $GLEW"
mkdir -p $BLD_GLEW ; cd $BLD_GLEW
rm -f CMakeCache.txt
$CMAKE -G"$GENERATOR" \
    -D CMAKE_INSTALL_PREFIX=$BIN_GLEW \
    -D CMAKE_OSX_ARCHITECTURES=$OSX_ARCHITECTURES \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_OSX_DEPLOYMENT_TARGET=$DEPL_TARG \
    -D CMAKE_CXX_FLAGS="$COMPILER_FLAGS" \
    $GLEW_OPTIONS \
    $SRC_GLEW/build/cmake
fi

if [ $STEP_COMPILE_GLEW ] ; then
echo "=== Build $GLEW"
cd $BLD_GLEW
make $MAKE_FLAGS
echo "=== Install $GLEW"
make install
fi

#-------------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_SOURCES_GML ] && [ ! -d $SRC_GLM ] ; then
cd $SRC
wget https://github.com/g-truc/glm/archive/$GLM_VERSION.tar.gz
tar -zxf $GLM_VERSION.tar.gz
rm $GLM_VERSION.tar.gz
fi

if [ $STEP_INFO_GLM ] ; then
echo "=== $GLM" ; cd $SRC_GLM ; grep -rn --include=*.txt "GLM_VERSION" CMakeLists.txt
fi

if [ $STEP_CONFIGURE_GLM ] ; then
echo "=== Configure $GLM"
mkdir -p $BLD_GLM ; cd $BLD_GLM
rm -f CMakeCache.txt
$CMAKE -G"$GENERATOR" \
    -D CMAKE_INSTALL_PREFIX=$BIN_GLM \
    -D CMAKE_OSX_ARCHITECTURES=$OSX_ARCHITECTURES \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_OSX_DEPLOYMENT_TARGET=$DEPL_TARG \
    -D CMAKE_CXX_FLAGS="$COMPILER_FLAGS" \
    -D GLM_STATIC_LIBRARY_ENABLE=ON \
    $SRC_GLM
fi

if [ $STEP_BUILD_GLM ] ; then
echo "=== Compile $GLM"
cd $BLD_GLM
make clean
make $MAKE_FLAGS

echo "=== Install $GLM"
make install
fi

#-------------------------------------------------------------------------------
if [ $STEP_DOWNLOAD_SOURCES_APP ] && [ ! -d $SRC_APP ] ; then
#if [ $STEP_DOWNLOAD_SOURCES_APP ] ; then
#mkdir -p $SRC_APP/.. ; cd $SRC_APP/..
cd $SRC
# For developers
#git clone https://github.com/bettar/miele-lxiv.git miele-lxiv-$MIELE_VERSION

#echo "MIELE_VERSION=$MIELE_VERSION, SRC_APP=$SRC_APP" 
#echo "MIELE=$MIELE, SRC=$SRC" 
#set -x # echo on

# For users (without project history)
git clone --branch ver$MIELE_VERSION --depth 1 https://github.com/bettar/miele-lxiv.git miele-lxiv-$MIELE_VERSION
#git clone --depth 5 https://github.com/bettar/miele-lxiv.git miele-lxiv-$MIELE_VERSION

touch $MIELE_HOME/Binaries/miele-lxiv-lite.zip
touch $MIELE_HOME/doc/build-steps/identity.conf
touch $MIELE_HOME/doc/build-steps/fixup-build-phase.sh
chmod +x $MIELE_HOME/doc/build-steps/fixup-build-phase.sh
fi

set -x # echo on

#BINARIES=$SRC_APP/Binaries
BINARIES=$MIELE_HOME/Binaries

if [ $STEP_UNZIP_BINARIES ] ; then
pushd $MIELE_HOME/doc/build-steps
echo "=== Unzip Binaries"
sed -i -e 's@SRCROOT=$(pwd)/../@SRCROOT="$(pwd)/../.."@g' ./unzip-binaries.sh  # For version 7.1.34
./unzip-binaries.sh
popd

# Initialize configuration files
#pushd $SRC_APP
pushd $MIELE_HOME
for hFile in url options
do
if [ ! -f $hFile.h ] ; then
    cp $hFile.in.h $hFile.h
    echo "Please edit $hFile.h to suit your preferences"
fi
done
popd
fi

if [ $STEP_REMOVE_SYMLINKS ] ; then
echo "=== Remove symbolic links from $BINARIES"
if [ $STEP_REMOVE_SYMLINKS_ICONV ] ;   then rm -f $BINARIES/libiconv ; fi
if [ $STEP_REMOVE_SYMLINKS_JPEG ] ;    then rm -f $BINARIES/libjpeg ; fi
if [ $STEP_REMOVE_SYMLINKS_TIFF ] ;    then rm -f $BINARIES/libtiff ; fi
if [ $STEP_REMOVE_SYMLINKS_XML2 ]  ;   then rm -f $BINARIES/libxml2 ; fi
if [ $STEP_REMOVE_SYMLINKS_ZLIB ] ;    then rm -f $BINARIES/zlib ; fi
if [ $STEP_REMOVE_SYMLINKS_VTK ]  ;    then rm -f $BINARIES/VTK ; fi
if [ $STEP_REMOVE_SYMLINKS_ITK ] ;     then rm -f $BINARIES/ITK ; fi
if [ $STEP_REMOVE_SYMLINKS_DCMTK ] ;   then rm -f $BINARIES/DCMTK ; fi
if [ $STEP_REMOVE_SYMLINKS_OPENJPG ] ; then rm -f $BINARIES/openjpeg ; fi
if [ $STEP_REMOVE_SYMLINKS_OPENSSL ] ; then rm -f $BINARIES/openssl ; fi
if [ $STEP_REMOVE_SYMLINKS_PNG ] ;     then rm -f $BINARIES/libpng ; fi
if [ $STEP_REMOVE_SYMLINKS_JASPER ] ;  then rm -f $BINARIES/Jasper ; fi
if [ $STEP_REMOVE_SYMLINKS_GLEW ] ;    then rm -f $BINARIES/GLEW ; fi
if [ $STEP_REMOVE_SYMLINKS_GLM ] ;     then rm -f $BINARIES/GLM ; fi
fi

if [ $STEP_CREATE_SYMLINKS ] ; then
echo "=== Create symbolic links in $BINARIES"
if [ $STEP_CREATE_SYMLINKS_ICONV ] ;   then ln -s $BIN_ICONV    $BINARIES/libiconv ; fi
if [ $STEP_CREATE_SYMLINKS_JPEG ] ;    then ln -s $BIN_JPEG     $BINARIES/libjpeg ; fi
if [ $STEP_CREATE_SYMLINKS_MING ] ;    then ln -s $BIN_MING     $BINARIES/libming ; fi
if [ $STEP_CREATE_SYMLINKS_TIFF ] ;    then ln -s $BIN_TIFF     $BINARIES/libtiff ; fi
if [ $STEP_CREATE_SYMLINKS_XML2 ] ;    then ln -s $BIN_XML2     $BINARIES/libxml2 ; fi
if [ $STEP_CREATE_SYMLINKS_ZLIB ] ;    then ln -s $BIN_ZLIB     $BINARIES/zlib ; fi
if [ $STEP_CREATE_SYMLINKS_VTK ] ;     then ln -s $BIN_VTK      $BINARIES/VTK ; fi
if [ $STEP_CREATE_SYMLINKS_ITK ] ;     then ln -s $BIN_ITK      $BINARIES/ITK ; fi
if [ $STEP_CREATE_SYMLINKS_DCMTK ] ;   then ln -s $BIN_DCMTK    $BINARIES/DCMTK ; fi
if [ $STEP_CREATE_SYMLINKS_OPENJPG ] ; then ln -s $BIN_OPENJPG  $BINARIES/openjpeg ; fi
if [ $STEP_CREATE_SYMLINKS_OPENSSL ] ; then ln -s $BIN_OPENSSL  $BINARIES/openssl ; fi
if [ $STEP_CREATE_SYMLINKS_PNG ] ;     then ln -s $BIN_PNG      $BINARIES/libpng ; fi
if [ $STEP_CREATE_SYMLINKS_JASPER ] ;  then ln -s $BIN_JASPER   $BINARIES/Jasper ; fi
if [ $STEP_CREATE_SYMLINKS_GLEW ] ;    then ln -s $BIN_GLEW     $BINARIES/GLEW ; fi
if [ $STEP_CREATE_SYMLINKS_GLM ] ;     then ln -s $BIN_GLM      $BINARIES/GLM ; fi
fi
