#!/bin/bash

: << '#__REM__'

Create a full-auto to iOS for the library specified. I do also builds the architecture download, more than one. Create architecture i386, x86_64, armv7, armv7s, arm64 by default.

#__REM__
TARGET_VERSION="1.3.1"
ARCHIVE_BASENAME="libjpeg-turbo"
OUTPUT_LIBS="libjpeg.a libturbojpeg.a"
DOWNLOAD_URL="http://softlayer-sng.dl.sourceforge.net/project/${ARCHIVE_BASENAME}/${TARGET_VERSION}/${ARCHIVE_BASENAME}-${TARGET_VERSION}.tar.gz"
#DOWNLOAD_URL="http://jaist.dl.sourceforge.net/project/libjpeg-turbo/1.3.90%20%281.4%20beta1%29/libjpeg-turbo-1.3.90.tar.gz"
#check the version
#http://sourceforge.net/projects/libjpeg-turbo/files/?source=navbar

#ios
DEPLOYMENT_TARGET="ios"
SDK_VERSION="8.1"
MIN_OS_VERSION="6.0"
ARCHS="i386 x86_64 armv7 armv7s arm64"
SIMD_OPTION="--with-simd"

#osx
#DEPLOYMENT_TARGET="osx"
#SDK_VERSION="10.9"
#MIN_OS_VERSION="10.9"
#RCHS="i386 x86_64"

DEBUG=0
VERBOSE=0

########################################

DEVELOPER=`xcode-select -print-path`
#DEVELOPER="/Applications/Xcode.app/Contents/Developer"

cd "`dirname \"$0\"`"
REPOROOT=$(pwd)

OUTPUT_DIR="${REPOROOT}/${ARCHIVE_BASENAME}-${TARGET_VERSION}-${DEPLOYMENT_TARGET}${SDK_VERSION}(${MIN_OS_VERSION})-static-lib"
mkdir -p "${OUTPUT_DIR}/include"
mkdir -p "${OUTPUT_DIR}/lib"

BUILD_DIR="${REPOROOT}/build"

SRC_DIR="${BUILD_DIR}/src"
mkdir -p "$SRC_DIR"
INTER_DIR="${BUILD_DIR}/built"
mkdir -p "$INTER_DIR"

########################################

#set -x

cd $SRC_DIR

set -e

if [ ! -e "${SRC_DIR}/${ARCHIVE_BASENAME}-${TARGET_VERSION}.tar.gz" ]; then
	cat <<_EOT_
##############################################################################
####
####  Downloading ${ARCHIVE_BASENAME}-${TARGET_VERSION}.tar.gz
####
##############################################################################
_EOT_
    echo "${SRC_DIR}/${ARCHIVE_BASENAME}-${TARGET_VERSION}.tar.gz"
	curl -O ${DOWNLOAD_URL}
	#wget ${DOWNLOAD_URL}
	echo "Done." ; echo ""
fi

cat <<_EOT_
##############################################################################
####
####  Using ${ARCHIVE_BASENAME}-${TARGET_VERSION}.tar.gz
####
##############################################################################
_EOT_
echo "${SRC_DIR}/${ARCHIVE_BASENAME}-${TARGET_VERSION}.tar.gz"
tar zxf ${ARCHIVE_BASENAME}-${TARGET_VERSION}.tar.gz -C $SRC_DIR

cd "${SRC_DIR}/${ARCHIVE_BASENAME}-${TARGET_VERSION}"

export ORIGINALPATH=$PATH

if [ "${DEPLOYMENT_TARGET}" == "ios" ]; then
	X68PLATFORM="iPhoneSimulator"
	CFLAG_VERSION_MIN="-mios-simulator-version-min"
	PLATFORM_DEPLOYMENT_TARGET="IPHONEOS_DEPLOYMENT_TARGET"
else
	X68PLATFORM="MacOSX"
	CFLAG_VERSION_MIN="-mmacosx-version-min"
	PLATFORM_DEPLOYMENT_TARGET="OSX_DEPLOYMENT_TARGET"
fi

for ARCH in ${ARCHS}
do
	if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ]; then
		PLATFORM=${X68PLATFORM}
	else
		PLATFORM="iPhoneOS"
	fi
	
	PREFIX="${INTER_DIR}/${PLATFORM}${SDK_VERSION}-${ARCH}.sdk"
	mkdir -p "${PREFIX}"

  export PATH=$ORIGINALPATH
	autoreconf -fiv

#  export PATH="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin:${DEVELOPER}/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  export PATH="/usr/bin:${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/usr/bin:${DEVELOPER}/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"

	cat <<_EOT_
##############################################################################
####
####   Configure ${ARCH}
####
##############################################################################
_EOT_

	case "${ARCH}" in
		"i386" )
			HOST_CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
			HOST_CFLAGS="-arch ${ARCH} -I${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/include ${CFLAG_VERSION_MIN}=${MIN_OS_VERSION} -DUSE_FILE32API"
			HOST_LDFLAGS="-arch ${ARCH} -I${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/include ${CFLAG_VERSION_MIN}=${MIN_OS_VERSION}"
			HOST_PLATFORMDIR=/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform
			HOST_SYSROOT=$HOST_PLATFORMDIR/Developer/SDKs/${PLATFORM}${SDK_VERSION}.sdk

			export ${PLATFORM_DEPLOYMENT_TARGET}=$SDK_VERSION
			if [ "${DEBUG}" == 0 ]; then
				HOST_CFLAGS="${HOST_CFLAGS} -O3 -DNDEBUG"
			else
				HOST_CFLAGS="${HOST_CFLAGS} -O0 -g -DDEBUG"
			fi

			./configure \
			    --prefix=${PREFIX} \
			    --build x86_64-apple-darwin \
			    --host i386-apple-darwin \
			    --enable-static \
			    --disable-shared \
			    --disable-silent-rules \
                ${SIMD_OPTION} \
                --with-pic \
                --with-sysroot ${HOST_SYSROOT} \
			    CC="$HOST_CC" LD="$HOST_CC" \
			    CFLAGS="-isysroot $HOST_SYSROOT $HOST_CFLAGS" \
			    LDFLAGS="-isysroot $HOST_SYSROOT $HOST_LDFLAGS"
		;;

		"x86_64" )
			HOST_CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
			HOST_CFLAGS="-arch ${ARCH} -I${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/include ${CFLAG_VERSION_MIN}=${MIN_OS_VERSION} -DUSE_FILE32API"
			HOST_LDFLAGS="-arch ${ARCH} -I${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/include ${CFLAG_VERSION_MIN}=${MIN_OS_VERSION}"
			HOST_PLATFORMDIR=/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform
			HOST_SYSROOT=$HOST_PLATFORMDIR/Developer/SDKs/${PLATFORM}${SDK_VERSION}.sdk

			export ${PLATFORM_DEPLOYMENT_TARGET}=$SDK_VERSION
			export NASM=/opt/local/bin/nasm
			if [ "${DEBUG}" == 0 ]; then
				HOST_CFLAGS="${HOST_CFLAGS} -O3 -DNDEBUG"
			else
				HOST_CFLAGS="${HOST_CFLAGS} -O0 -g -DDEBUG"
			fi

			./configure \
			    --prefix=${PREFIX} \
			    --build x86_64-apple-darwin \
			    --host x86_64-apple-darwin \
			    --enable-static \
			    --disable-shared \
                --disable-silent-rules \
                ${SIMD_OPTION} \
                --with-pic \
                --with-sysroot ${HOST_SYSROOT} \
			    CC="$HOST_CC" LD="$HOST_CC" \
			    CFLAGS="-isysroot $HOST_SYSROOT $HOST_CFLAGS" \
			    LDFLAGS="-isysroot $HOST_SYSROOT $HOST_LDFLAGS"
		;;

		"armv7" | "armv7s" | "arm64" )
	    HOST_CC=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang
	    HOST_CFLAGS="-arch ${ARCH} -I${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/include -miphoneos-version-min=${MIN_OS_VERSION} -DUSE_FILE32API"
	    HOST_LDFLAGS="-arch ${ARCH} -I${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/include -miphoneos-version-min=${MIN_OS_VERSION}"
	    HOST_PLATFORMDIR=/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform
	    HOST_SYSROOT=$HOST_PLATFORMDIR/Developer/SDKs/${PLATFORM}${SDK_VERSION}.sdk

	    export ${PLATFORM_DEPLOYMENT_TARGET}=$SDK_VERSION
			if [ "${DEBUG}" == 0 ]; then
				HOST_CFLAGS="${HOST_CFLAGS} -O3 -DNDEBUG"
			else
				HOST_CFLAGS="${HOST_CFLAGS} -O0 -g -DDEBUG"
			fi

	    ./configure \
	        --prefix=${PREFIX} \
	        --build x86_64-apple-darwin \
	        --host arm-apple-darwin \
	        --enable-static \
	        --disable-shared \
	        --disable-silent-rules \
            ${SIMD_OPTION} \
	        --with-pic \
	        --with-sysroot ${HOST_SYSROOT} \
	        CC="$HOST_CC" LD="$HOST_CC" \
	        CFLAGS="-isysroot $HOST_SYSROOT $HOST_CFLAGS $HOST_CFLAGS_64" \
	        LDFLAGS="-isysroot $HOST_SYSROOT $HOST_LDFLAGS $HOST_LDFLAGS_64"
		;;
	esac
	echo "Done." ; echo ""

		cat <<_EOT_
##############################################################################
####
####   Make ${ARCH}
####
##############################################################################
_EOT_
	make V=${VERBOSE} clean
	make -j4 V=${VERBOSE}
	make -j4 V=${VERBOSE} install
	echo "Done." ; echo ""
done

rm -rf "${SRC_DIR}/${ARCHIVE_BASENAME}-${TARGET_VERSION}"
########################################

	cat <<_EOT_
##############################################################################
####
####   Build library ...
####
##############################################################################
_EOT_
for OUTPUT_LIB in ${OUTPUT_LIBS}; do
	INPUT_LIBS=""
	for ARCH in ${ARCHS}; do
		if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ]; then
			PLATFORM=${X68PLATFORM}
		else
			PLATFORM="iPhoneOS"
		fi
		INPUT_ARCH_LIB="${INTER_DIR}/${PLATFORM}${SDK_VERSION}-${ARCH}.sdk/lib/${OUTPUT_LIB}"
		if [ -e $INPUT_ARCH_LIB ]; then
			INPUT_LIBS="${INPUT_LIBS} ${INPUT_ARCH_LIB}"
		fi
	done
	# Combine the three architectures into a universal library.
	if [ -n "$INPUT_LIBS"  ]; then
		lipo -create $INPUT_LIBS -output "${OUTPUT_DIR}/lib/${OUTPUT_LIB}"
	else
		echo "${OUTPUT_LIB} does not exist, skipping (are the dependencies installed?)"
	fi
done

for ARCH in ${ARCHS}; do
	if [ "${ARCH}" == "i386" ] || [ "${ARCH}" == "x86_64" ]; then
		PLATFORM=${X68PLATFORM}
	else
		PLATFORM="iPhoneOS"
	fi
	cp -R ${INTER_DIR}/${PLATFORM}${SDK_VERSION}-${ARCH}.sdk/include/* ${OUTPUT_DIR}/include/
	if [ $? == "0" ]; then
		# We only need to copy the headers over once. (So break out of forloop
		# once we get first success.)
		break
	fi
	echo "Done." ; echo ""
done


for OUTPUT_LIB in ${OUTPUT_LIBS}; do
    lipo -info "${OUTPUT_DIR}/lib/${OUTPUT_LIB}"
done
echo "Done all." ; echo ""
