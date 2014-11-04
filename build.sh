#!/bin/bash

LINES_SHOW="20"
LINES_PATTERN="BUILD SUCCEEDED"
IOSSDK_VER="8.1"
SDK_OS="-sdk iphoneos${IOSSDK_VER}"
SDK_SIM="-sdk iphonesimulator${IOSSDK_VER}"

BUILD_CONFIG="-configuration Release"

rm -rf "lib"
mkdir -p "lib"
xcodebuild -project libjpeg-turbo-ios.xcodeproj $BUILD_CONFIG -target turbojpeg $SDK_OS build || exit ${PIPESTATUS[0]}
xcodebuild -project libjpeg-turbo-simulator.xcodeproj $BUILD_CONFIG -target turbojpeg $SDK_SIM build || exit ${PIPESTATUS[0]}

lipo -output "lib/libturbojpeg-universal.a" -create "lib/libturbojpeg-arm.a" "lib/libturbojpeg-simulator.a"
xcrun -sdk iphoneos lipo -info "lib/libturbojpeg-universal.a"
