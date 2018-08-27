#!/usr/bin/env bash

if [[ ${BASH_VERSION} != 4* ]]; then
    echo "bash 4.0 required" 1>&2
    exit 1
fi

set -o pipefail
set -e

shopt -s extglob
shopt -s nullglob

for command in unlzma wget; do
    if ! which "${command}" &>/dev/null; then
        echo "Cannot run \`${command}\`. Please read compiling.txt." 1>&2
        exit 1
    fi
done

if tar --help | grep bsdtar &>/dev/null; then
    echo "Running \`tar\` is bsdtar :(. Please read compiling.txt." 1>&2
    exit 1
fi

xcode=$(xcodebuild -sdk macosx -version Path)

rm -rf sysroot
mkdir sysroot
cd sysroot

repository=http://apt.saurik.com/
distribution=tangelo
component=main
architecture=iphoneos-arm

declare -A dpkgz
dpkgz[gz]=gunzip
dpkgz[lzma]=unlzma

function extract() {
    package=$1
    url=$2

    wget -O "${package}.deb" "${url}"
    for z in lzma gz; do
        compressed=data.tar.${z}

        if ar -x "${package}.deb" "${compressed}" 2>/dev/null; then
            ${dpkgz[${z}]} "${compressed}"
            break
        fi
    done

    if ! [[ -e data.tar ]]; then
        echo "unable to extract package" 1>&2
        exit 1
    fi

    ls -la data.tar
    tar -xf ./data.tar
    rm -f data.tar
}

declare -A urls

urls[apt7]=http://apt.saurik.com/debs/apt7_0.7.25.3-7_iphoneos-arm.deb
urls[apt7-lib]=http://apt.saurik.com/debs/apt7-lib_0.7.25.3-12_iphoneos-arm.deb
urls[coreutils]=http://apt.saurik.com/debs/coreutils_7.4-11_iphoneos-arm.deb

if [[ 0 ]]; then
    wget -qO- "${repository}dists/${distribution}/${component}/binary-${architecture}/Packages.bz2" | bzcat | {
        regex='^([^ \t]*): *(.*)'
        declare -A fields

        while IFS= read -r line; do
            if [[ ${line} == '' ]]; then
                package=${fields[package]}
                if [[ -n ${urls[${package}]} ]]; then
                    filename=${fields[filename]}
                    urls[${package}]=${repository}${filename}
                fi

                unset fields
                declare -A fields
            elif [[ ${line} =~ ${regex} ]]; then
                name=${BASH_REMATCH[1],,}
                value=${BASH_REMATCH[2]}
                fields[${name}]=${value}
            fi
        done
    }
fi

for package in "${!urls[@]}"; do
    extract "${package}" "${urls[${package}]}"
done

rm -f *.deb

mkdir -p usr/include
cd usr/include

mkdir CoreFoundation
wget -O CoreFoundation/CFUniChar.h "http://www.opensource.apple.com/source/CF/CF-550/CFUniChar.h?txt"

mkdir -p WebCore
wget -O WebCore/WebCoreThread.h 'http://www.opensource.apple.com/source/WebCore/WebCore-658.28/wak/WebCoreThread.h?txt'

ln -s /System/Library/Frameworks/IOKit.framework/Headers IOKit
