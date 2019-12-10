#!/bin/bash

# --------------------------------------------------------------
# iOSOpenDev -- iOS Open Development (http://www.iOSOpenDev.com)
# Copyright (C) 2012 Spencer W.S. James <dev@iosopendev.com>
# --------------------------------------------------------------
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
# --------------------------------------------------------------
# iOSOpenDev is an independent project and has not been authorized, sponsored, or otherwise approved by Apple Inc.
# IOS is a registered trademark of Cisco and is used under license by Apple Inc.
# Xcode is a registered trademark of Apple Inc.
# --------------------------------------------------------------

export setCmd="set -eo pipefail"
$setCmd

# path #
export PATH=/opt/iOSOpenDev/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH

# script #

export scriptName="${0##*/}"
export scriptVer="1.2.2"

export iOSOpenDevPath="/opt/iOSOpenDev"
export backupFileExt=".iOSOpenDev"

export userName="${SUDO_USER-$USER}"
export userGroup=`id -g $userName`
export userHome=`eval echo ~$userName`
export bashProfileFiles=("$userHome/.bash_profile" "$userHome/.bash_login" "$userHome/.profile")

export tempDirsFile="`mktemp -d -t $scriptName`/tempdirs"
touch "$tempDirsFile"

unset LANG

# panic and cleanup #

function cleanup()
{
  local exitCode=$?
	set +e
	trap - $signals
	removeTempData
	exit $exitCode
}
function panic()
{
	local exitCode=$1
	set +e
	shift
	[[ "$@" == "" ]] || echo "$@" >&2
	exit $exitCode
}
export signals="0 1 2 3 15"
trap cleanup $signals

function removeTempData()
{
	local tempDirs
	if [[ -f "$tempDirsFile" ]]; then
		tempDirs=(`cat "$tempDirsFile"`)
		for td in "${tempDirs[@]}"; do
			rm -rf "$td" || true
		done
		rm -rf "`dirname $tempDirsFile`" || true
	fi
}
function getTempDir()
{
	$setCmd
	local tempDir
	tempDir=`mktemp -d -t $scriptName` || \
		panic $? "Failed to create temporary directory"
	echo "$tempDir" >> "$tempDirsFile" || \
		panic $? "Failed to echo into $tempDirsFile"
	echo "$tempDir"
}

# common functions #

function downloadFile() # args: sourceUrl, targetPath
{
	local sourceUrl="$1"
	local targetPath="$2"
	local curlPath

	mkdir -p "${targetPath%/*}" || \
		panic $? "Failed to make directory: ${targetPath%/*}"

	curlPath=`which curl` || \
		panic $? "Failed to get curl path"

	"$curlPath" --silent --insecure --output "$targetPath" "$sourceUrl" || \
		panic $? "Failed to download $sourceUrl to $targetPath"
}

function extractTar() # args: tarPath, outputPath
{
	local tarPath="$1"
	local outputPath="$2"
	
	tar -C "$outputPath" -zxf "$tarPath" || \
		panic $? "Failed to extract $tarPath to $outputPath"
}

function downloadGithubTarball() # args: url, outputDir, title
{
	$setcmd

	local url="$1"
	local outputDir="$2"
	local title="$3"
	local tempDirForTar
	local tempDirForFiles
	local untardDir
	local tarFile="file.tar.gz"

	echo "Downloading $title from Github..."

	tempDirForTar=`getTempDir`
	tempDirForFiles=`getTempDir`
	
	downloadFile "$url" "$tempDirForTar/$tarFile"
	
	extractTar "$tempDirForTar/$tarFile" "$tempDirForFiles"

	untardDir=`find "$tempDirForFiles/"* -type d -depth 0` || \
		panic $? "Failed to get untar'ed directory name of $tempDirForTar/$tarFile"

	mkdir -p "$outputDir" || \
		panic $? "Failed to make directory: $outputDir"

	cp -fR "$untardDir/"* "$outputDir/"
}

function changeMode()
{
	local mode="$1"
	local target="$2"
	local recursive="$3"
	local options

	[[ $recursive != "true" ]] || \
		options="-R"

	if [[ -e "$target" ]]; then
		chmod $options "$mode" "$target" || \
			panic $? "Failed to change mode to $mode on $target"
	fi
}

# base argument functions #

function determineUserBashProfileFile()
{
	$setCmd

	local f
	local filePath
	
	for f in "${bashProfileFiles[@]}"; do
		if [[ -f "$f" ]]; then
			filePath="$f"
			echo "" >> "$f" || \
				panic $? "Failed to echo into $f"
			break
		fi
	done
	
	if [[ $filePath == "" ]]; then
		filePath="$bashProfileFiles"

		touch "$filePath" || \
			panic $? "Failed to touch $filePath"
			
		chown "$userName:$userGroup" "$filePath" || \
			panic $? "Failed to change owner-group of $filePath"
		
		changeMode 0600 "$filePath"
	fi
	
	# return #
	echo "$filePath"
}

function addToFileIfMissing() # args: filePath, pattern, value
{
	local filePath="$1"
	local pattern="$2"
	local value="$3"
	local doesContain

	doesContain=`doesFileContain "$filePath" "$pattern"`
	
	[[ $doesContain == "true" ]] || \
		echo "$value" >> "$filePath" || \
			panic $? "Failed to echo into $filePath"	
}

function doesFileContain() # args: filePath, pattern
{
	$setCmd
	
	local filePath="$1"
	local pattern="$2"
	local perlValue
	local funcReturn
	
	perlValue=`perl -ne 'if (/'"$pattern"'/) { print "true"; exit; }' "$filePath"` || \
		panic $? "Failed to perl"

	if [[ $perlValue == "true" ]]; then
		funcReturn="true"
	else
		funcReturn="false"
	fi
	
	# return #
	echo $funcReturn
}

# sdk argument functions #

function getSdkProperty()
{
	$setCmd

	local sdk="$1"
	local propertyName="$2"

	propertyValue=`xcodebuild -version -sdk $sdk $propertyName` || \
		panic $? "Failed to get $sdk SDK property $propertyName"

	[[ $propertyValue != "" ]] || \
		panic 1 "Value of $sdk SDK property $propertyName cannot be empty"

	# return #
	echo "$propertyValue"
}

function getPlatformName()
{
	$setCmd

	local sdk="$1"
	local iosSdkPlatformPath
	local platformDir
	local platformName
	
	iosSdkPlatformPath=`getSdkProperty $sdk PlatformPath`	
	platformDir="${iosSdkPlatformPath##*/}"
	platformName="${platformDir%.*}"
	
	# return #
	echo "$platformName"
}

function writeDefaults()
{
	local plistPath="$1"	
	shift 1

	defaults write "${plistPath%.*}" "$@" || \
		panic $? "Failed to write defaults to $plistPath"
}

function copyFile()
{
	cp -f "$1" "$2" || \
		panic $? "Failed to copy file $1 to $2"
}

function requireBackup()
{
	[[ ! -f "$1" || -f "${1}${backupFileExt}" ]] || \
		copyFile "$1" "${1}${backupFileExt}"
}

function requireFile()
{
	local filePath="$1"
	local touchFileIfNotFound="$2"
	
	if [[ ! -f "$filePath" ]]; then
		if [[ $touchFileIfNotFound == "true" ]]; then
			touch "$filePath" || \
				panic $? "Failed to touch $filePath"	
		else
			panic 1 "File not found: $filePath"
		fi
	fi
}

function modifySdkSettings()
{
	local sdk="$1"
	local iosSdkPath
	local sdkSettingsPList
	
	iosSdkPath=`getSdkProperty $sdk Path`

	# backup SDKSettings.plist
	sdkSettingsPList="$iosSdkPath/SDKSettings.plist"
	requireFile "$sdkSettingsPList" false
	requireBackup "$sdkSettingsPList"

	# change SDKSettings.plist
	writeDefaults "$sdkSettingsPList" DefaultProperties "-dict-add" CODE_SIGNING_REQUIRED "-bool" NO
	writeDefaults "$sdkSettingsPList" DefaultProperties "-dict-add" ENTITLEMENTS_REQUIRED "-bool" NO
	writeDefaults "$sdkSettingsPList" DefaultProperties "-dict-add" AD_HOC_CODE_SIGNING_ALLOWED "-bool" YES
	
	# fix mode
	changeMode 0644 "$sdkSettingsPList"
}

function addXcodeSpecs()
{
	local sdk="$1"
	local platformName="$2"
	local iosSdkPlatformPath
	local xcspecFileNamePrefix
	
	iosSdkPlatformPath=`getSdkProperty $sdk PlatformPath`
	
	# get *.xcspec filename prefix
	xcspecFileNamePrefix="$platformName"	
	[[ ! $xcspecFileNamePrefix =~ "Simulator" ]] || xcspecFileNamePrefix="iPhone Simulator "

	# backup *PackageTypes.xcspec
	iosPackagesTypesXCSpec="$iosSdkPlatformPath/Developer/Library/Xcode/Specifications/${xcspecFileNamePrefix}PackageTypes.xcspec"	
	requireFile "$iosPackagesTypesXCSpec" false
	requireBackup "$iosPackagesTypesXCSpec"

	# modify *PackageTypes.xcspec
	addXcodeSpec "$iosPackagesTypesXCSpec" "com.apple.package-type.mach-o-executable" '{"ProductReference":{"IsLaunchable":"YES","FileType":"compiled.mach-o.executable","Name":"\$(EXECUTABLE_NAME)"},"DefaultBuildSettings":{"EXECUTABLE_NAME":"\$(EXECUTABLE_PREFIX)\$(PRODUCT_NAME)\$(EXECUTABLE_VARIANT_SUFFIX)\$(EXECUTABLE_SUFFIX)","EXECUTABLE_PATH":"\$(EXECUTABLE_NAME)","EXECUTABLE_SUFFIX":"","EXECUTABLE_PREFIX":""},"Type":"PackageType","Name":"Mach-O Executable","Identifier":"com.apple.package-type.mach-o-executable","Description":"Mach-O executable"}'
	addXcodeSpec "$iosPackagesTypesXCSpec" "com.apple.package-type.mach-o-dylib" '{"ProductReference":{"IsLaunchable":"NO","FileType":"compiled.mach-o.dylib","Name":"\$(EXECUTABLE_NAME)"},"DefaultBuildSettings":{"EXECUTABLE_NAME":"\$(EXECUTABLE_PREFIX)\$(PRODUCT_NAME)\$(EXECUTABLE_VARIANT_SUFFIX)\$(EXECUTABLE_SUFFIX)","EXECUTABLE_PATH":"\$(EXECUTABLE_NAME)","EXECUTABLE_SUFFIX":"","EXECUTABLE_PREFIX":""},"Type":"PackageType","Name":"Mach-O Dynamic Library","Identifier":"com.apple.package-type.mach-o-dylib","Description":"Mach-O dynamic library"}'

	# backup *ProductTypes.xcspec
	iosProductTypesXCSpec="$iosSdkPlatformPath/Developer/Library/Xcode/Specifications/${xcspecFileNamePrefix}ProductTypes.xcspec"
	requireFile "$iosProductTypesXCSpec" false
	requireBackup "$iosProductTypesXCSpec"

	# modify *ProductTypes.xcspec
	addXcodeSpec "$iosProductTypesXCSpec" "com.apple.product-type.tool" '{"IconNamePrefix":"TargetExecutable","PackageTypes":["com.apple.package-type.mach-o-executable"],"Name":"Command-line Tool","Type":"ProductType","DefaultTargetName":"Command-line Tool","DefaultBuildProperties":{"REZ_EXECUTABLE":"YES","LIBRARY_FLAG_NOSPACE":"YES","FULL_PRODUCT_NAME":"\$(EXECUTABLE_NAME)","INSTALL_PATH":"\/usr\/bin","CODE_SIGNING_ALLOWED":"YES","GCC_INLINES_ARE_PRIVATE_EXTERN":"YES","GCC_SYMBOLS_PRIVATE_EXTERN":"YES","GCC_DYNAMIC_NO_PIC":"NO","FRAMEWORK_FLAG_PREFIX":"-framework","ENTITLEMENTS_ALLOWED":"YES","STRIP_STYLE":"all","EXECUTABLE_PREFIX":"","MACH_O_TYPE":"mh_execute","EXECUTABLE_SUFFIX":"","LIBRARY_FLAG_PREFIX":"-l"},"Identifier":"com.apple.product-type.tool","Class":"PBXToolProductType","Description":"Standalone command-line tool"}'
	addXcodeSpec "$iosProductTypesXCSpec" "com.apple.product-type.library.dynamic" '{"IconNamePrefix":"TargetLibrary","PackageTypes":["com.apple.package-type.mach-o-dylib"],"Description":"Dynamic library","Type":"ProductType","DefaultBuildProperties":{"EXECUTABLE_SUFFIX":".\$(EXECUTABLE_EXTENSION)","PRIVATE_HEADERS_FOLDER_PATH":"\/usr\/include","REZ_EXECUTABLE":"YES","FULL_PRODUCT_NAME":"\$(EXECUTABLE_NAME)","LD_DYLIB_INSTALL_NAME":"\$(DYLIB_INSTALL_NAME_BASE:standardizepath)\/\$(EXECUTABLE_PATH)","DYLIB_COMPATIBILITY_VERSION":"1","INSTALL_PATH":"\/usr\/lib","FRAMEWORK_FLAG_PREFIX":"-framework","LIBRARY_FLAG_NOSPACE":"YES","GCC_INLINES_ARE_PRIVATE_EXTERN":"YES","CODE_SIGNING_ALLOWED":"YES","STRIP_STYLE":"debugging","EXECUTABLE_EXTENSION":"dylib","MACH_O_TYPE":"mh_dylib","DYLIB_CURRENT_VERSION":"1","PUBLIC_HEADERS_FOLDER_PATH":"\/usr\/include","DYLIB_INSTALL_NAME_BASE":"\$(INSTALL_PATH)","LIBRARY_FLAG_PREFIX":"-l"},"DefaultTargetName":"Dynamic Library","Class":"PBXDynamicLibraryProductType","Name":"Dynamic Library","Identifier":"com.apple.product-type.library.dynamic"}'
}

function addXcodeSpec()
{
	local specFile="$1"
	local specId="$2"
	local specData="$3"
	local fileContainsSpecId
	local tempDir
	local tempFile
	local defaultsRead
	
	fileContainsSpecId=`doesFileContain "$specFile" "$specId"`
	
	if [[ $fileContainsSpecId == "false" ]]; then
			
		tempDir=`getTempDir`		
		tempFile="$tempDir/`basename $specFile`.plist"
				
		plutil -convert json -o "$tempFile" "$specFile" || \
			panic $? "Failed to convert XCSpec file $specFile to JSON to temporary file $tempFile"
		
		perl -i -pe 's/\]$/,'"$specData"'\]/' "$tempFile" || \
			panic $? "Failed to add XCSpec to temporary file $tempFile"
		
		plutil -convert binary1 "$tempFile" || \
			panic $? "Failed to convert temporary file $tempFile to binary"

		copyFile "$tempFile" "$specFile"
	fi
}

function readDefaultsValue()
{
	$setCmd
	
	local plistPath="$1"
	local propertyName="$2"
	local value
	
	value=`defaults read "${plistPath%.*}" "$propertyName"` || \
		panic $? "Failed to read defaults property $propertyName from $plistPath"

	# return #
	echo "$value"
}

function addSymlinksToPathAvailableDuringBuilds()
{
	local sdk="$1"
	local iosSdkPlatformPath

	iosSdkPlatformPath=`getSdkProperty $sdk PlatformPath`
	
	# add symlinks to path that's available during an Xcode Build Phase Run Script
	createSymlink "$iOSOpenDevPath/bin/iosod" "$iosSdkPlatformPath/Developer/usr/bin/iosod"
	createSymlink "$iOSOpenDevPath/bin/ldid" "$iosSdkPlatformPath/Developer/usr/bin/ldid"
}

function createSymlink()
{
	local sourcePath="$1"
	local linkPath="$2"
	
	rm -f "$linkPath" || \
		panic $? "Failed to remove file: $linkPath"
	
	ln -fhs "$sourcePath" "$linkPath" || \
		panic $? "Failed to create symbolic link $linkPath -> $sourcePath"
}

function createSdkPrivateHeaderSymlinks()
{
	local sdk="$1"
	local iosSdkPath
	local privateFWsDir
	local privateFwBinaries
	local fullPath
	local shortPath
	local sourcePath
	local targetPath

	iosSdkPath=`getSdkProperty $sdk Path`
	
	[[ -d "$iosSdkPath" ]] || \
		panic 1 "SDK directory not found: $iosSdkPath"
		
	privateFWsDir="$iosSdkPath/System/Library/PrivateFrameworks"
	
	[[ -d "$privateFWsDir" ]] || \
		panic 1 "PrivateFramework directory not found: $privateFWsDir"

	privateFwBinaries=($(find "$privateFWsDir" -type f -perm +111 -ipath "*.framework/*"))
	
	for f in "${privateFwBinaries[@]}"; do
		fullPath=`dirname "$f"`
		shortPath="${fullPath/#$privateFWsDir}"
		
		sourcePath="${iOSOpenDevPath}/frameworks${shortPath}/Headers"
		targetPath="${fullPath}/Headers"
		
		if [[ -d "$sourcePath" ]] && [[ ! "$sourcePath" -ef "$targetPath" ]]; then
			if [[ -L "$targetPath" ]]; then
				echo "Symlink already exists: $targetPath"
			elif [[ -e "$targetPath" ]]; then
				echo "File or directory already exists: $targetPath"
			else
				createSymlink "$sourcePath" "$targetPath"
			fi
		fi
	done
}

# script functions #

function requireOptionValue()
{
	[[ "$2" != "" ]] || \
		panic 1 "Missing value for $1 option"
}

function showUsage()
{
	panic 1 \
"$scriptName (v${scriptVer}) -- iOSOpenDev Setup
Usages:
   $scriptName base
   $scriptName sdk [-sdk <sdk>] [-d <directory>] [-which]

Arguments:
   base               Set up iOSOpenDev base, Xcode templates and private
                      framework header files.

   sdk                Set up latest iOS SDK for \"open\" development.

Options:
   -sdk <sdk>         SDK name and, optionally, version as one word to set
                      up. If version is omitted, latest version of named SDK
                      is used. If <sdk> is entirely omitted, latest iOS SDK is
                      used.

   -d <directory>     Set environment variable DEVELOPER_DIR to <directory> to
                      target specific Developer Tools. Use this option when
                      multiple versions of Xcode are installed.

   -which             Print which SDK and Developer Tools directory will be
                      used by default if -sdk <sdk> and -d <directory> are
                      not used.
"
}

# begin script ... #

devToolsDir="`xcode-select --print-path`" || \
	panic $? "Failed to get Xcode developer directory"
	
if [[ ! -d "$DEVELOPER_DIR" ]] && [[ -d "$devToolsDir" ]]; then
	export DEVELOPER_DIR="$devToolsDir"
fi

case "$1" in

base)
	
	# get iOSOpenDev base, frameworks and templates #
	
	mkdir -p "$iOSOpenDevPath" || \
		panic $? "Failed to make directory: $iOSOpenDevPath"

	downloadGithubTarball "https://nodeload.github.com/kokoabim/iOSOpenDev/tar.gz/master" "$iOSOpenDevPath" "iOSOpenDev base"
	downloadGithubTarball "https://nodeload.github.com/kokoabim/iOSOpenDev-Xcode-Templates/tar.gz/master" "$iOSOpenDevPath/templates" "Xcode templates"
	downloadGithubTarball "https://nodeload.github.com/kokoabim/iOSOpenDev-Framework-Header-Files/tar.gz/master" "$iOSOpenDevPath/frameworks" "framework header files"

	# symlink to templates #
	
	echo "Creating symlink to Xcode templates..."
	
	userDevDir="$userHome/Library/Developer"
	userTemplatesDir="$userDevDir/Xcode/Templates"
	
	if [[ ! -d "$userTemplatesDir" ]]; then
		mkdir -p "$userTemplatesDir" || \
			panic $? "Failed to make directory: $userTemplatesDir"
			
		chown -R "$userName:$userGroup" "$userDevDir" || \
			panic $? "Failed to change ownership-group of $userDevDir"
	fi
	
	ln -fhs "$iOSOpenDevPath/templates" "$userTemplatesDir/iOSOpenDev"
	
	# bash profile #
	
	echo "Modifying Bash personal initialization file..."
	
	userBashProfileFile=`determineUserBashProfileFile`

	addToFileIfMissing "$userBashProfileFile" "^(export)? *iOSOpenDevPath=.*" "export iOSOpenDevPath=$iOSOpenDevPath"
	addToFileIfMissing "$userBashProfileFile" "^(export)? *iOSOpenDevDevice=.*" "export iOSOpenDevDevice="
	addToFileIfMissing "$userBashProfileFile" "^(export)? *PATH=.*(\\\$iOSOpenDevPath\\/bin|${iOSOpenDevPath//\//\\/}\\/bin).*" "export PATH=$iOSOpenDevPath/bin:\$PATH"
;;
	
sdk)
	
	shift 1
	
	sdk="iphoneos" # default to latest iphoneos sdk
	printWhich="false"
	
	while [[ $1 != "" ]]; do
	case "$1" in
		-sdk)
			requireOptionValue "$1" "$2"
			sdk="$2"
			shift 2
		;;
		-d)
			requireOptionValue "$1" "$2"
			export DEVELOPER_DIR="$2"
			
			[[ -d "$DEVELOPER_DIR" ]] || \
				panic 1 "Directory not found: $DEVELOPER_DIR"

			shift 2
		;;
		-which)
			printWhich="true"
			shift 1
		;;
		*) panic 1 "Invalid option: $1" ;;
	esac
	done

	# get sdk platform-name and version
	
	platformName=`getPlatformName "$sdk"`
	sdkVersion=`getSdkProperty "$sdk" "SDKVersion"`
	
	[[ "$printWhich" == "false" ]] || \
		panic 1 "SDK: ${platformName}${sdkVersion}
Developer Tools: $DEVELOPER_DIR"

	echo "Setting up $platformName $sdkVersion SDK..."

	# modify SDK settings
	
	echo "Modifying SDK settings..."
	modifySdkSettings "$sdk"
	
	# symlink to dumped private frameworks header files
	
	echo "Symlinking to private frameworks header files..."
	createSdkPrivateHeaderSymlinks "$sdk"

	# add Xcode specifications
	
	echo "Adding specifications to platform..."
	addXcodeSpecs "$sdk" "$platformName"

	# create symlinks so be available in PATH during Xcode builds
	
	echo "Creating symlinks in platform bin..."
	addSymlinksToPathAvailableDuringBuilds "$sdk"

;;

*) showUsage ;;
esac

# done #

exit 0