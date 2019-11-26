#!/usr/bin/env bash

echo "Cleaning up..."
rm -rf bin/ src/

echo "Updating submodules..."
git submodule update --init --recursive

echo "Copying sources..."
mkdir src/
find FLEX/Classes -type f \( -name "*.h" -o -name "*.m" \) -exec cp {} src/ \;

BIN_NAME="libFLEX.dylib"
IOS_VERSION_MIN=7.0

DEVELOPER_DIR="$(xcode-select -print-path)"
#DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
SDK_ROOT_OS=$DEVELOPER_DIR/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
SDK_ROOT_SIMULATOR=$DEVELOPER_DIR/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk

ARCHS="armv7 arm64"
INPUT=$(find src -type f -name "*.m")

for ARCH in ${ARCHS}
do
	DIR=bin/${ARCH}
	mkdir -p ${DIR}
	echo "Building for ${ARCH}..."
	if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]];
	then
		SDK_ROOT=${SDK_ROOT_SIMULATOR}
		IOS_VERSION_MIN_FLAG=-mios-simulator-version-min
	else
		SDK_ROOT=${SDK_ROOT_OS}
		IOS_VERSION_MIN_FLAG=-mios-version-min
	fi
		FRAMEWORKS=${SDK_ROOT}/System/Library/Frameworks/
		INCLUDES=${SDK_ROOT}/usr/include/
		LIBRARIES=${SDK_ROOT}/usr/lib/

		clang -I${INCLUDES} -F${FRAMEWORKS} -L${LIBRARIES} -Os -dynamiclib -isysroot ${SDK_ROOT} -arch ${ARCH} -fobjc-arc ${IOS_VERSION_MIN_FLAG}=${IOS_VERSION_MIN} -framework Foundation -framework UIKit -framework CoreGraphics -framework QuartzCore -framework ImageIO -lz -lsqlite3 ${INPUT} -o ${DIR}/${BIN_NAME}
done

echo "Creating universal binary..."
FAT_BIN_DIR="bin/universal"
mkdir -p ${FAT_BIN_DIR}
lipo -create bin/**/${BIN_NAME} -output ${FAT_BIN_DIR}/${BIN_NAME}

echo "Copying dylib..."
DYLIB_PATH="./layout/Library/Application Support/FLEXLoader/"
if [ ! -d "$DYLIB_PATH" ]; then
	mkdir -p ./layout/Library/Application\ Support/FLEXLoader/
fi

cp -f bin/universal/libFLEX.dylib layout/Library/Application\ Support/FLEXLoader

echo "Done."
