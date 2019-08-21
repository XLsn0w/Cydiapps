#  _    _____    _____   _    _ 
# (_)  / ____|  / ____| | |  | |
#  _  | (___   | (___   | |__| |
# | |  \___ \   \___ \  |  __  |
# | |  ____) |  ____) | | |  | |
# |_| |_____/  |_____/  |_|  |_|
                              


iSSH_ROOT_DIR=`cat ~/.issh/rootdir`

function ilog(){
	echo -e "\033[32m[I]:$1 \033[0m"
}

function sshRunCMD(){
	ilog "Run $1"
	ssh root@localhost -p 2222 -o stricthostkeychecking=no "$1"
}

function sshRunCMDClean(){
	ssh root@localhost -p 2222 "$1"	
}

function iFileExsit(){
	# if exist return "1", Not return "0"
	ret=`sshRunCMDClean "[ -f $1 ] && echo "1" || echo "0""`
	echo $ret
}

function iDirExsit(){
	ret=`sshRunCMDClean "[ -d $1 ] && echo "1" || echo "0""`
	echo $ret
}

function removeRSA(){
	# cat ~/.ssh/known_hosts | grep -v "2222" && ( > ~/.ssh/known_hosts)|| (cat /dev/null > ~/.ssh/known_hosts)
	sed -i "" '/.*2222.*/d' ~/.ssh/known_hosts
}

function isshNoPWD(){
	if [[ "$1" = "clean" ]]; then
		ilog "rm authorized_keys and xia0_ssh.lock from device"
		sshRunCMD "rm /var/root/\.ssh/authorized_keys; rm /var/root/\.ssh/xia0_ssh.lock"
		return
	fi
	removeRSA
	#  check is need password
	ssh -p 2222 -o PasswordAuthentication=no -o StrictHostKeyChecking=no root@localhost "exit" 2>/dev/null ; 
	if [[ $? == 0 ]]; then

		ilog "++++++++++++++++++ Nice to Work :) +++++++++++++++++++++";

	else

		ilog "scp id_rsa.pub to connect iDevice [1/2]"
		scp -P 2222 -o StrictHostKeyChecking=no ~/.ssh/id_rsa.pub root@localhost:/tmp > /dev/null 2>&1

		ilog "add id_rsa.pub to authorized_keys [2/2]"
		
		sshScript="[ -d /var/root/\.ssh ] \
		|| (mkdir -p /var/root/\.ssh);	\
		[ -f /var/root/\.ssh/authorized_keys ] \
		&& (cat /tmp/id_rsa.pub >> /var/root/\.ssh/authorized_keys;touch /var/root/\.ssh/xia0_ssh.lock) \
		|| (mv /tmp/id_rsa.pub /var/root/\.ssh/authorized_keys;touch  /var/root/\.ssh/xia0_ssh.lock)"

		# cat /dev/null > ~/.ssh/known_hosts
		ssh root@localhost -p 2222 -o stricthostkeychecking=no $sshScript 2> /dev/null
		
		ilog "++++++++++++++++++ Nice to Work :) +++++++++++++++++++++";
	fi

}



function checkIproxy(){
	ret=`lsof -i tcp:2222 | grep "iproxy"`
	if [[ "$?" = "0" ]]; then
		iproxyPid=`echo $ret | awk '{print $2}'`
		ilog "iproxy process for 2222 port alive, pid=$iproxyPid"
	else
		ilog "iproxy process for 2222 port dead, start iproxy 2222 22"
		(iproxy 2222 22 &) > /dev/null 2>&1
		sleep 1
	fi
}

function printUsage(){
	ilog "First Run issh on new idevice, you will only input ssh password twice!"
	printf "issh %-30s %-20s \n" "show [dylib/Preferences/apps]" "show some info" 
	printf "issh %-30s %-20s \n" "scp remote/local local/remote" "cp file from connect device or to device"
	printf "issh %-30s %-20s \n" "dump" "Use Frida(frida-ios-dump) to dump IPA"
	printf "issh %-30s %-20s \n" "debug [-a wechat -x backboard]" "auto sign debugserver[Test on iOS9/10/11/12] and happy to debug"
	printf "issh %-30s %-20s \n" "install" "install app form local to connect device"
	printf "issh %-30s %-20s \n" "device" "show some info about device"
	printf "issh %-30s %-20s \n" "apps" "show all app info(Bundleid,BundleExecutable,BundleDisplayName, Fullpath)"
	printf "issh %-30s %-20s \n" "shell" "get the shell of connect device"
	printf "issh %-30s %-20s \n" "clean" "rm authorized_keys and xia0_ssh.lock from device"
	printf "issh %-30s %-20s \n" "run" "execute shell command on connect device"
	printf "issh %-30s %-20s \n" "respring" "kill SpringBoard"
	printf "issh %-30s %-20s \n" "ldrestart" "kill all daemon without reJailbreak"
	printf "issh %-30s %-20s \n" "reboot" "!!!if do reboot, you need reJailbreak!"
	printf "issh %-30s %-20s \n" "help/-h" "show this help info"
}

function issh(){	
	# $setCmd
	# usage/help
	if [[ "$1" = "help" || "$1" = "-h" || $# == 0 ]]; then
		printUsage
		return	
	fi

	checkIproxy

	# run isshNoPWD for no pwd login later
	if [[ "$1" = "clean" ]]; then
		# _sshRunCMD "cat $2" > "$3"
		isshNoPWD clean
	else
		isshNoPWD
	fi

	# xia0 command
	if [ "$1" = "show" ];then
		case $2 in
			dylib )
				sshRunCMD "ls /Library/MobileSubstrate/DynamicLibraries"
				;;

			pref* )
				sshRunCMD "ls /var/mobile/Library/Preferences/"
				;;
			
			app* )
				cfgutil get installedApps
				;;	

			profile* )
				
				cfgutil get provisioningProfiles
				
				;;
			*)
				;;
		esac
	fi

	if [[ "$1" = "device" ]]; then
		device_name=`cfgutil get name`
		device_osver=`cfgutil get firmwareVersion`
		device_type=`cfgutil get deviceType`
		device_UDID=`cfgutil get UDID`
		device_serial=`cfgutil get serialNumber`

		printf "%-20s %-20s \n" "DeviceName" "$device_name"
		printf "%-20s %-20s \n" "OSVersion" "$device_osver"
		printf "%-20s %-20s \n" "DeviceType" "$device_type"
		printf "%-20s %-20s \n" "UDID" "$device_UDID"
		printf "%-20s %-20s \n" "SerialNumber" "$device_serial"
	fi

	if [[ "$1" = "scp" ]]; then
		# _sshRunCMD "cat $2" > "$3"
		if [[ -f $2 || -d $2 ]]; then
			ilog "$2 is local file, so cp it to device"
			scp -P 2222 -r $2 root@localhost:$3
			return
		fi
		ilog "$2 is remote file, so cp it from device"
		scp -P 2222 -r root@localhost:$2 $3 
	fi

	if [[ "$1" = "debug" ]]; then
		debugArgs=${@:2:$#}
		#  create iOSRE dir if need
		ret=`iDirExsit /iOSRE`
		if [[ "$ret" = "1" ]]; then
			ilog "iOSRE dir exist"
		else
			ilog "iOSRE dir not exist"
			sshRunCMD "mkdir -p /iOSRE/tmp;mkdir -p /iOSRE/dylib;mkdir -p /iOSRE/deb;mkdir -p /iOSRE/tools"
		fi
		
		# check iproxy 1234 port is open?
		ret=`lsof -i tcp:1234 | grep "iproxy"`
		if [[ "$?" = "0" ]]; then
			iproxyPid=`echo $ret | awk '{print $2}'`
			ilog "iproxy process for 1234 port alive, pid=$iproxyPid"
		else
			ilog "iproxy process for 1234 port dead, start iproxy 1234 1234"
			(iproxy 1234 1234 &) > /dev/null 2>&1
			sleep 1
		fi

		# check debugserver is alive

		killDebugserverIfAlive="ps -e | grep debugserver | grep -v grep; [[ $? == 0 ]] && (killall -9 debugserver 2> /dev/null)"

		sshRunCMD "$killDebugserverIfAlive"
		
		# check tools debugserver
		ret=`iFileExsit /iOSRE/tools/debugserver`
		if [[ "$ret" = "1" ]]; then
			ilog "/iOSRE/tools/debugserver file exist, Start debug..."
			sshRunCMD "/iOSRE/tools/debugserver 127.0.0.1:1234 $debugArgs"
		else
			ilog "/iOSRE/tools/debugserver file not exist"

			# create ent.xml 
			sshRunCMD 'cat > /iOSRE/tmp/ent.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.backboardd.debugapplications</key>
    <true/>
    <key>com.apple.backboardd.launchapplications</key>
    <true/>
    <key>com.apple.diagnosticd.diagnostic</key>
    <true/>
    <key>com.apple.frontboard.debugapplications</key>
    <true/>
    <key>com.apple.frontboard.launchapplications</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>
    <key>com.apple.springboard.debugapplications</key>
    <true/>
    <key>com.apple.system-task-ports</key>
    <true/>
    <key>get-task-allow</key>
    <true/>
    <key>platform-application</key>
    <true/>
    <key>run-unsigned-code</key>
    <true/>
    <key>task_for_pid-allow</key>
    <true/>
</dict>
</plist> 
EOF'
		
			debugCMD="cp /Developer/usr/bin/debugserver /iOSRE/tmp/;\
			cd /iOSRE/tmp;ldid -Sent.xml /iOSRE/tmp/debugserver;\
			chmod +x  /iOSRE/tmp/debugserver;\
			cp /iOSRE/tmp/debugserver /iOSRE/tools/;\
			"
			sshRunCMD "$debugCMD"
			sshRunCMD "/iOSRE/tools/debugserver 127.0.0.1:1234 $debugArgs"
		fi

	fi

	if [[ "$1" = "install" ]]; then
		cfgutil install-app "$2"
	fi

	if [[ "$1" =~ "app" ]]; then
		function handleXargs(){
			infoPlist=$1
			scp -P 2222 -r "root@localhost:$infoPlist" /tmp/isshAppTest
		}

		mkdir -p /tmp/isshAppTest
		# CFBundleDisplayName
		# sshRunCMDClean "find /var/containers/Bundle/Application/ -regex \"[^\.]*/[^\.]*\.app/Info\.plist$\" -print0 | \
		# xargs -0 -i echo \"root@localhost:{}\" /tmp/isshAppTest " | xargs -n 2
		# sshRunCMDClean "find /var/containers/Bundle/Application/ -regex \"[^\.]*/[^\.]*\.app/Info\.plist$\"" | \
		# xargs -I% sh -c "echo "\n%"; scp -P 2222 -r root@localhost:\"'%'\" /tmp/isshAppTest > /dev/null 2>&1; defaults read /tmp/isshAppTest/Info.plist CFBundleIdentifier;";
		sshRunCMD "find /var/containers/Bundle/Application/ -regex \"[^\.]*/[^\.]*\.app$\" -exec sh -c \" echo '=========';echo \"{}\";defaults read \"{}/Info.plist\" CFBundleIdentifier; \
		defaults read \"{}/Info.plist\" CFBundleExecutable; defaults read \"{}/Info.plist\" CFBundleDisplayName; \" \;"

		sshRunCMD "find /Applications/ -regex \"[^\.]*/[^\.]*\.app$\" -exec sh -c \" echo '=========';echo \"{}\";defaults read \"{}/Info.plist\" CFBundleIdentifier; \
		defaults read \"{}/Info.plist\" CFBundleExecutable; defaults read \"{}/Info.plist\" CFBundleDisplayName; \" \;"
	fi

	if [[ "$1" = "dump" ]]; then
		dumpArgs=${@:2:$#}
		dumpFile=$iSSH_ROOT_DIR"/frida-ios-dump/dump.py"; 
		echo $dumpFile

		if [ ! -f $dumpFile ];then
			cd $iSSH_ROOT_DIR && git clone https://github.com/AloneMonkey/frida-ios-dump.git;
			pip install --user -r $iSSH_ROOT_DIR"/frida-ios-dump/requirements.txt" --upgrade
		fi

		python "$dumpFile" $dumpArgs
	fi

	if [[ "$1" = "iOSRE" ]]; then
		ret=`iDirExsit /iOSRE`
		if [[ "$ret" = "1" ]]; then
			ilog "iOSRE dir exist"
		else
			ilog "iOSRE dir not exist"
			sshRunCMD "mkdir -p /iOSRE/tmp;mkdir -p /iOSRE/dylib;mkdir -p /iOSRE/deb;mkdir -p /iOSRE/tools"
		fi
	fi

	if [[ "$1" = "run" ]]; then
		sshRunCMD "$2"
	fi

	if [ "$1" = "shell" ];then
		ssh root@localhost -p 2222 -o stricthostkeychecking=no
	fi

	if [[ "$1" = "respring" ]]; then
		sshRunCMD "killall -9 SpringBoard"
	fi

	if [[ "$1" = "ldrestart" ]]; then
		sshRunCMD "/usr/bin/ldrestart"
	fi

	if [[ "$1" = "reboot" ]]; then
		sshRunCMD "reboot"
	fi
}