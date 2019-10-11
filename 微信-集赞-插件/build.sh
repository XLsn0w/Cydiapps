function xecho(){
	echo -e "\033[32m$1 \033[0m"
}

cydiaRepo="$HOME/xia0/iOSRE/cydiarepo/debs"
ROOT=$(cd `dirname $0`; pwd)


xecho "[1] Clear hosts file."
cat /dev/null > ~/.ssh/known_hosts

xecho "[2] Remove 0ld package."
rm -fr $ROOT/packages

xecho "[3] Compile..."
make -s clean package #> /dev/null 2>&1

xecho "[4] Copy deb to xia0Repo if need..."

if [[ -z $1 || "$1" != "cydia" ]]; then
	xecho "[*] you do not want to copy deb to cydia repo"

else
	xecho "[*] you do want to copy deb to cydia repo, let's go"
	if [[ "$1" = "cydia" &&  -d $cydiaRepo ]]; then
		
		debName=`ls $ROOT/packages/ 2>/dev/null | awk -F'_' '{print $1}'` 

		if [[ -z $debName || $debName == "" ]]; then
			xecho "[-] No deb file in $ROOT/packages"
			exit
		fi

		xecho "[*] Target deb file: $debName"

		ls $cydiaRepo | grep -q "$debName"

		if [[ "$?" == "0" ]]; then
			xecho "[*] Old $debName in xia0Repo, delete it!"
			rm "$cydiaRepo/$debName"*
		else
			xecho "[*] $debName not in xia0Repo"
		fi

		xecho "[*] Do copy $debName to $cydiaRepo"
		cp $ROOT/packages/*.deb $cydiaRepo

	else
		xecho "[*] $cydiaRepo not exsist, do not need copy deb file."
	fi
fi

xecho "[5] Install to device"
make install

xecho "[+] All Done."