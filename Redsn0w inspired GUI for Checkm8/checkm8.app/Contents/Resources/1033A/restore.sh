#!/bin/bash

# $0 <exec> $device <ipsw>

if [ "$#" == 1 ]; then

	if [ ! -e "/usr/local/bin/brew" ]; then
		echo "OOOOF, brew is not installed? Installing..."
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	else
		echo "[+] Installing dependencies"
		brew install libtool automake lsusb openssl libzip pkg-config libplist

		if [ -e "ipwndfu_public" ]; then
			cd ipwndfu_public && git pull origin master
			cd ..
		else
			git clone https://github.com/MatthewPierson/ipwndfu_public
		fi

        cd ipwndfu_public
        string=$(lsusb | grep -c "checkm8")
        until [ $string = 1 ];
        do
            killall iTunes && killall iTunesHelper
            echo "Waiting 10 seconds to allow you to enter DFU mode"
            sleep 10
            echo "Attempting to get into pwndfu mode"
            echo "Please just enter DFU mode again on each reboot"
            echo "The script will run ipwndfu again and again until the device is in PWNDFU mode"
            ./ipwndfu -p
            string=$(lsusb | grep -c "checkm8")
        done
        
        sleep 3

        python rmsigchks.py
        cd ..
        
		if [ $string == 1 ]; then
			echo "We seem to be in pwned DFU mode!"

			if [ -e "build" ]; then
				echo "[+] Build folder exists! Updating only!"
				cd build
				for d in *
					do
						(cd $d && git pull origin master)
				done
				cd ..
			else
				echo "[+] Build folder does not exist! Grabbing dependencies and installing!"
				mkdir -p build && cd build
				git clone https://github.com/libimobiledevice/libusbmuxd
				git clone https://github.com/libimobiledevice/libirecovery
				git clone https://github.com/libimobiledevice/libimobiledevice
				git clone https://github.com/tihmstar/libfragmentzip
				git clone --recursive https://github.com/merculous/futurerestore
				git clone --recursive https://github.com/tihmstar/liboffsetfinder64
				git clone --recursive https://github.com/tihmstar/img4tool
				git clone --recursive https://github.com/s0uthwest/tsschecker 

				export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"

				cd libusbmuxd
				./autogen.sh
				make && make install
				cd ../libirecovery
				./autogen.sh
				make && make install
				cd ../libimobiledevice
				./autogen.sh
				make && make install
				cd ../libfragmentzip
				./autogen.sh
				make && make install
				cd ../futurerestore
				./autogen.sh
				make && make install
				cd ../liboffsetfinder64
				./autogen.sh
				make && make install
				cd ../img4tool
				./autogen.sh
				make && make install
				cd ../tsschecker
				./autogen.sh
				make && make install

				echo "[+] Dependencies should now be installed and compiled."
			fi

			rm -rfv ipsw dummy_file *.im4p *.prepatched *.raw *.img4 shsh downgrade* 
			echo "Killing iTunes as this will be quite annoying with what we are going to do."
			killall iTunes && killall iTunesHelper
			mkdir -p ipsw
			mkdir -p shsh
			unzip -d ipsw $1
			cp -rv ipsw/Firmware/Mav7Mav8-7.60.00.Release.bbfw .
            ls
            ./igetnonce | grep 'n53ap' &> /dev/null
            if [ $? == 0 ]; then
               echo "Supported Device"
               device="iPhone6,2"
               echo $device
            fi

            ./igetnonce | grep 'n51ap' &> /dev/null
            if [ $? == 0 ]; then
               echo "Supported Device"
               device="iPhone6,1"
               echo $device
            fi

            ./igetnonce | grep 'j71AP' &> /dev/null
            if [ $? == 0 ]; then
               echo "Supported Device"
               device="iPad4,1"
               echo $device
            fi

            ./igetnonce | grep 'j72AP' &> /dev/null
            if [ $? == 0 ]; then
               echo "Supported Device"
               device="iPad4,2"
               echo $device
            fi

            ./igetnonce | grep 'j85AP' &> /dev/null
            if [ $? == 0 ]; then
               echo "Supported Device"
               device="iPad4,4"
               echo $device
            fi

            ./igetnonce | grep 'j86AP' &> /dev/null
            if [ $? == 0 ]; then
               echo "Supported Device"
               device="iPad4,5"
               echo $device
            fi

            ./igetnonce | grep 'j85AP' &> /dev/null
            if [ $? == 0 ]; then
               echo "Supported Device"
               device="iPad4,4"
               echo $device
            fi

            if [ -z "$device" ]
            then
                echo "Either unsupported device or no device found."
                echo "Exiting.."
                exit
            else
                echo "Supported device found."
            fi

            #Credit to @dora2_yururi for ECID/Apnonce getting stuff from Nudaoaddu

            ret=$(./igetnonce 2>/dev/null | grep ECID)
            ecidhex=$(echo $ret | cut -d '=' -f 2 )
            ecidhex2=$(echo $ecidhex | tr '[:lower:]' '[:upper:]')
            echo $ecidhex2 >/dev/null
            ecid=$(echo "obase=10; ibase=16; $ecidhex2" | bc)
            echo $ecid

			if [ $device == iPhone6,1 ] || [ $device == iPhone6,2 ]; then # If iPhone 5S
				mv -v ipsw/Firmware/dfu/*.iphone6*.im4p .

				if [ $device == iPhone6,1 ]; then
					cp -rv ipsw/Firmware/all_flash/sep-firmware.n51.RELEASE.im4p .
				else
					cp -rv ipsw/Firmware/all_flash/sep-firmware.n53.RELEASE.im4p .
				fi

				img4tool -e --iv f2aa35f6e27c409fd57e9b711f416cfe --key 599d9b18bc51d93f2385fa4e83539a2eec955fce5f4ae960b252583fcbebfe75 -o iBSS.raw iBSS.iphone6.RELEASE.im4p
				img4tool -e --iv 75a06e85e2d9835827334738bb84ce73 --key 15c61c585d30ab07497f68aee0a64c433e4b1183abde4cfd91c185b9a70ab91a -o iBEC.raw iBEC.iphone6.RELEASE.im4p
				./iBoot64Patcher iBSS.raw iBSS.prepatched
				./iBoot64Patcher iBEC.raw iBEC.prepatched
				img4tool -c iBSS.im4p -t ibss iBSS.prepatched
				img4tool -c iBEC.im4p -t ibec iBEC.prepatched
				tsschecker -d "$device" -i 10.3.3 -o -m manifests/BuildManifest_"$device"_1033_OTA.plist -e $ecid -s --save-path shsh
				mv -v shsh/*.shsh* shsh/stitch.shsh2
				img4tool -c iBSS.img4 -p iBSS.im4p -s shsh/stitch.shsh2 
				img4tool -c iBEC.img4 -p iBEC.im4p -s shsh/stitch.shsh2
				cp -v iBSS.img4 ipsw/Firmware/dfu/iBSS.iphone6.RELEASE.im4p
				cp -v iBEC.img4 ipsw/Firmware/dfu/iBEC.iphone6.RELEASE.im4p
			fi

			if [ $device == iPad4,1 ] || [ $device == iPad4,2 ] || [ $device == iPad4,3 ]; then # If iPad Air
				mv -v ipsw/Firmware/dfu/iBEC.ipad4.RELEASE.im4p .

				if [ $device == iPad4,1 ]; then
					cp -rv ipsw/Firmware/all_flash/sep-firmware.j71.RELEASE.im4p .
				fi

				if [ $device == iPad4,2 ]; then
					cp -rv ipsw/Firmware/all_flash/sep-firmware.j72.RELEASE.im4p .
				fi 

				if [ $device == iPad4,3 ]; then
					cp -rv ipsw/Firmware/all_flash/sep-firmware.j73.RELEASE.im4p .
				fi 

				img4tool -e --iv a83dfcc277766ccb5da4220811ec2407 --key b4f8d062a97628231a289ae2a50647c309c43030577dca7fc2eee3a13ddb51ea -o iBEC.raw iBEC.ipad4.RELEASE.im4p
				./iBoot64Patcher iBEC.raw iBEC.prepatched 
				img4tool -c iBEC.im4p -t ibec iBEC.prepatched 

					if [ $device == iPad4,3 ]; then
						tsschecker -d "$device" --boardconfig j73AP -i 10.3.3 -o -m manifests/BuildManifest_"$device"_1033_OTA.plist -e $ecid -s --save-path shsh
					else
						tsschecker -d "$device" -i 10.3.3 -o -m manifests/BuildManifest_"$device"_1033_OTA.plist -e $ecid -s --save-path shsh
					fi

				mv -v shsh/*.shsh* shsh/stitch.shsh2 
				img4tool -c iBEC.img4 -p iBEC.im4p -s shsh/stitch.shsh2 
				cp -v iBEC.img4 ipsw/Firmware/dfu/iBEC.ipad4.RELEASE.im4p
			fi

			if [ $device == iPad4,4 ] || [ $device == iPad4,5 ]; then # If iPad Mini 2
				mv -v ipsw/Firmware/dfu/iBEC.ipad4b.RELEASE.im4p .

				if [ $device == iPad4,4 ]; then
					cp -rv ipsw/Firmware/all_flash/sep-firmware.j85.RELEASE.im4p .
				else
					cp -rv ipsw/Firmware/all_flash/sep-firmware.j86.RELEASE.im4p .
				fi

				img4tool -e --iv 3067a2585100890afd3b266926ac254b --key dcdf5a9eb3ae0464e984333e15876faa116525ca4b61f361283a808ca09c7480 -o iBEC.raw iBEC.ipad4b.RELEASE.im4p
				./iBoot64Patcher iBEC.raw iBEC.prepatched 
				img4tool -c iBEC.im4p -t ibec iBEC.prepatched 
				mv -v shsh/*.shsh* shsh/stitch.shsh2 
				img4tool -c iBEC.img4 -p iBEC.im4p -s shsh/stitch.shsh2 
				cp -v iBEC.img4 ipsw/Firmware/dfu/iBEC.ipad4b.RELEASE.im4p 
			fi

			cd ipsw
			zip ../downgrade.ipsw -r9 *
			cd ..
			echo "checkm8" >> dummy_file
			raw=$(irecovery -q | grep NONC)
			apnonce=$(echo $raw | cut -d ':' -f 2)
            
            if [ $device == iPad4,1 ] || [ $device == iPad4,2 ] || [ $device == iPad4,3 ] || [ $device == iPad4,4 ] || [ $device == iPad4,5 ]; then
                irecovery -f dummy_file
                irecovery -f iBEC.img4

                if [ $device == iPad4,3 ]; then
                    tsschecker -d "$device" --boardconfig j73AP -i 10.3.3 -o -m manifests/BuildManifest_"$device"_1033_OTA.plist -e $ecid --apnonce $apnonce -s
                else
                    tsschecker -d "$device" -i 10.3.3 -o -m manifests/BuildManifest_"$device"_1033_OTA.plist -e $ecid --apnonce $apnonce -s
                fi
            fi

            if [ $device == iPhone6,1 ] || [ $device == iPhone6,2 ]; then
                irecovery -f dummy_file
                irecovery -f iBSS.img4
                irecovery -f iBEC.img4
                tsschecker -d "$device" -i 10.3.3 -o -m manifests/BuildManifest_"$device"_1033_OTA.plist -e $ecid --apnonce $apnonce -s
            fi

            mv -v *.shsh* shsh/apnonce.shsh2
            echo "Done prepping files! Time to downgrade!!!"

            echo "****RESTORING!****"
            echo "Waiting for device to reconnect..."
            sleep 5
            futurerestore -t shsh/apnonce.shsh2 -s sep-firmware.*.RELEASE.im4p -m manifests/BuildManifest_"$device"_1033_OTA.plist -b Mav7Mav8-7.60.00.Release.bbfw -p manifests/BuildManifest_"$device"_1033_OTA.plist downgrade.ipsw

            echo "Cleaning up :D"
            rm -rfv dummy_file iBSS* iBEC* *.bbfw *.im4p downgrade ipsw
            echo "If you see this, we're done! Shoutout to the devs and Matty for making this possible! - Merculous"
            echo "P.S. You know, this could look even better and be even easier if we port it to Python :D"

        else
            echo "Did not find checkm8 within lsusb. We are going to exit. Please enter pwned DFU and run again!"
            exit
        fi
    fi
else
    echo "Usage: $0 PathToIpsw (ipsw must be in this directory)"
    echo "Example: $0 iPhone_4.0_64bit_10.3.3_14G60_Restore.ipsw"
fi
