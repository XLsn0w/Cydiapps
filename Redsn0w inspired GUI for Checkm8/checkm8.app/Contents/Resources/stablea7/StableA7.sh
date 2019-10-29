#!/bin/bash

beta=true

echo "==> Checking for brew..."
which brew > /dev/null
if [ $? -ne 0 ]; then
	echo "==> Homebrew is not installed on your Mac. For StableA7 to work properly, you need to install it."

	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/TRCL-lamothecolby/Modified-Homebrew/master/Homebrew?token=ANL6ZJ7PVC2LI5MTEO4Q7FS5WXSJK)"
fi

echo "==> Installing dependencies..."
brew install autoconf automake bsdiff libimobiledevice libtool libzip lsusb openssl pkg-config wget

echo "==> Checking for libirecovery..."
which irecovery > /dev/null
if [ $? -ne 0 ]; then
	echo "==> Downloading libirecovery..."
	git clone https://github.com/libimobiledevice/libirecovery.git
	
	echo "==> Making libirecovery..."
	cd libirecovery
	./autogen.sh && make
	
	echo
	echo "==> Installing libirecovery. This might ask for your password..."
	sudo make install
	cd ..
	rm -rf libirecovery
fi

echo "==> Checking for libfragmentzip..."
if [ ! -d /usr/local/include/libfragmentzip ]; then
	echo "==> Downloading libfragmentzip..."
	git clone https://github.com/tihmstar/libfragmentzip.git
	
	echo "==> Making libfragmentzip..."
	cd libfragmentzip
	./autogen.sh && make
	
	echo
	echo "==> Installing libfragmentzip. This might ask for your password..."
	sudo make install
	cd ..
	rm -rf libfragmentzip
fi

clear
echo "**************** StableA7 ****************"
echo
echo "=> By Luke:"
echo "=>   - u/TheLukeGuy"
echo "=>   - @ConsoleLogLuke"
echo

if [ $beta == true ]; then
	echo "==> WARNING: This is a beta version. Things might not work properly or at all."
	echo
fi

echo "==> Creating work directory..."
if [ -d StableA7 ]; then
	rm -r StableA7
fi
mkdir StableA7
cd StableA7

echo "==> Downloading binaries..."
wget -O bin.zip https://gitlab.com/devluke/stablea7/-/archive/master/stablea7-master.zip?path=bin -q --show-progress
unzip -q bin.zip
cp -r stablea7-master-bin/bin .
chmod +x bin/*
rm -r stablea7-master-bin bin.zip

echo "==> Downloading patches..."
wget -O patch.zip https://gitlab.com/devluke/stablea7/-/archive/master/stablea7-master.zip?path=patch -q --show-progress
unzip -q patch.zip
cp -r stablea7-master-patch/patch .
rm -r stablea7-master-patch patch.zip

echo "==> Renaming futurerestore binary..."
if [ $patch -eq 1 ]; then
	mv bin/futurerestore_normal bin/futurerestore
elif [ $patch -eq 2 ]; then
	mv bin/futurerestore_rsu bin/futurerestore
	
	echo "==> Downloading rsu..."
	wget -O rsu.zip https://gitlab.com/devluke/stablea7/raw/master/rsu.zip -q --show-progress
	unzip -q rsu.zip
	rm rsu.zip

	echo "==> Moving rsu to /rsu. This might ask for your password..."
	sudo rm -rf /rsu 2> /dev/null
	sudo mv rsu /
fi

echo "==> Waiting for device..."
info=
while :; do
	info=$(bin/igetnonce 2> /dev/null | grep ,)
	if [ $? -eq 0 ]; then
		break
	fi
done

identifier=${info#*, }
identifier=${identifier%% *}
echo "==> $identifier found!"

	echo "==> Downloading IPSW..."
	wget -O restore.ipsw https://api.ipsw.me/v4/ipsw/download/$identifier/14G60 -q --show-progress
fi

echo "==> Extracting IPSW..."
unzip -q -d ipsw restore.ipsw

model=
if [ $identifier == iPhone6,1 ] || [ $identifier == iPhone6,2 ]; then
	model=iphone6
elif [ $identifier == iPad4,1 ] || [ $identifier == iPad4,2 ]; then
	model=ipad4
elif [ $identifier == iPad4,4 ] || [ $identifier == iPad4,5 ]; then
	model=ipad4b
fi

echo "==> Copying iBEC/iBSS..."
cp ipsw/Firmware/dfu/iBEC.$model.RELEASE.im4p ibec.im4p
cp ipsw/Firmware/dfu/iBSS.$model.RELEASE.im4p ibss.im4p

echo "==> Patching iBEC/iBSS..."
bspatch ibec.im4p ibec.patched.im4p patch/ibec_$model.patch
bspatch ibss.im4p ibss.patched.im4p patch/ibss_$model.patch

echo "==> Copying patched iBEC/iBSS to IPSW..."
rm ipsw/Firmware/dfu/iBEC.$model.RELEASE.im4p
rm ipsw/Firmware/dfu/iBSS.$model.RELEASE.im4p
cp ibec.patched.im4p ipsw/Firmware/dfu/iBEC.$model.RELEASE.im4p
cp ibss.patched.im4p ipsw/Firmware/dfu/iBSS.$model.RELEASE.im4p

echo "==> Creating custom IPSW..."
cd ipsw
zip -q ../custom.ipsw -r0 *
cd ..

echo "==> Cleaning up..."
rm -r ibec.im4p ibss.im4p patch restore.ipsw


echo "==> Removing signature checks..."
python rmsigchks.py > /dev/null

cd ..

echo "==> Sending test file to device..."
echo "Hello from StableA7!" >> test.txt
irecovery -f test.txt

echo "==> Sending patched iBSS/iBEC to device..."
irecovery -f ibss.patched.im4p
irecovery -f ibec.patched.im4p

echo "==> Downloading OTA manifests..."
wget -O manifests.zip https://gitlab.com/devluke/stablea7/raw/master/A7_10.3.3_OTA_Manifests.zip -q --show-progress
unzip -q manifests.zip
rm manifests.zip

echo "==> Waiting for device to reconnect..."
while :; do
	bin/igetnonce &> /dev/null
	if [ $? -eq 0 ]; then
		break
	fi
done

echo "==> Getting ECID and ApNonce..."
ecid=$(bin/igetnonce | grep ECID=)
ecid=${ecid#*ECID=}
apnonce=$(bin/igetnonce | grep ApNonce=)
apnonce=${apnonce#*ApNonce=}

echo "==> Copying OTA manifest..."
cp 10.3.3/BuildManifest_"$identifier"_1033_OTA.plist BuildManifest.plist

if [ $identifier == iPhone6,1 ] || [ $identifier == iPhone6,2 ] || [ $identifier == iPad4,2 ] || [ $identifier == iPad4,5 ]; then
	echo "==> Copying baseband..."
	cp ipsw/Firmware/Mav7Mav8-7.60.00.Release.bbfw baseband.bbfw
	baseband=true
else
	baseband=false
fi

echo "==> Copying SEP..."
if [ $identifier == iPad4,1 ]; then
	cp ipsw/Firmware/all_flash/sep-firmware.j71.RELEASE.im4p sep.im4p
elif [ $identifier == iPad4,2 ]; then
	cp ipsw/Firmware/all_flash/sep-firmware.j72.RELEASE.im4p sep.im4p
elif [ $identifier == iPad4,4 ]; then
	cp ipsw/Firmware/all_flash/sep-firmware.j85.RELEASE.im4p sep.im4p
elif [ $identifier == iPad4,5 ]; then
	cp ipsw/Firmware/all_flash/sep-firmware.j86.RELEASE.im4p sep.im4p
elif [ $identifier == iPhone6,1 ]; then
	cp ipsw/Firmware/all_flash/sep-firmware.n51.RELEASE.im4p sep.im4p
elif [ $identifier == iPhone6,2 ]; then
	cp ipsw/Firmware/all_flash/sep-firmware.n53.RELEASE.im4p sep.im4p
fi

echo "==> Requesting ticket..."
bin/tsschecker -e $ecid -d $identifier -s -o -i 9.9.10.3.3 --buildid 14G60 -m BuildManifest.plist --apnonce $apnonce > /dev/null
mv *.shsh ota.shsh

echo "==> Cleaning up..."
rm -r 10.3.3 ibec.patched.im4p ibss.patched.im4p ipsw ipwndfu test.txt

echo "==> Restoring device to 10.3.3..."
status=
if [ $baseband == true ]; then
	bin/futurerestore -t ota.shsh -s sep.im4p -m BuildManifest.plist -b baseband.bbfw -p BuildManifest.plist custom.ipsw
	status=$?
else
	bin/futurerestore -t ota.shsh -s sep.im4p -m BuildManifest.plist --no-baseband custom.ipsw
	status=$?
fi

if [ $status -ne 0 ]; then
	echo
	echo "==> Restoring failed. Exiting recovery mode..."
	bin/futurerestore --exit-recovery &> /dev/null
	exit 1
fi

echo "==> Deleting work directory..."
cd ..
rm -r StableA7

echo
echo "==> Restore succeeded! Enjoy 10.3.3!"
