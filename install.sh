#!/bin/sh

ADBBINARY="adb.linux"
OS=$(uname)

BASEDIR="$( dirname "$0" )"
cd "$BASEDIR"

chmod +x files/adb.linux
chmod +x files/adb.mac
chmod +x files/unzip.linux

if [ "$OS" = "Linux" ]; then
	ADBBINARY="adb.linux"
fi

if [ "$OS" = "Darwin" ]; then
	ADBBINARY="adb.mac"
fi

echo ""
echo "=============================================="
echo "=                                            ="
echo "=             Easy Root Tool v12             ="
echo "=      Supports various Xperia devices       ="
echo "=            created by zxz0O0               ="
echo "=                                            ="
echo "=     http://forum.xda-developers.com/       ="
echo "=        showthread.php?p=53448680           ="
echo "=                                            ="
echo "=       Many thanks to:                      ="
echo "=       - [NUT]                              ="
echo "=       - geohot                             ="
echo "=       - MohammadAG                         ="
echo "=       - cubeundcube                        ="
echo "=       - nhnt11                             ="
echo "=       - xsacha                             ="
echo "=                                            ="
echo "=============================================="
echo ""

cd ./files
SONYRIC=1
unset ANDROID_SERIAL

if [ ! -f libexploit.so ];
then
	if [ ! -f tr.apk ];
	then
		echo "============================================="
		echo "tr.apk not found. Trying to download from"
		echo "https://towelroot.com/tr.apk"
		echo "============================================="
		curl -\# -O https://towelroot.com/tr.apk
		echo ""
	fi
	if [ ! -f tr.apk ];
	then
		echo "============================================="
		echo "Error downloading tr.apk with curl"
		echo "Please download towelroot from https://towelroot.com"
		echo "and save it as tr.apk in folder files/"
		echo ""
		echo "If you still have problems, please disable"
		echo "your Antivirus and try again"
		echo "============================================="
		echo "Press any key to continue"
		read tmpvar
		echo ""
		if [ ! -f tr.apk ];
		then
			echo "Error: tr.apk not found. Aborting..."
			echo "Press any key to quit"
			read tmpvar
			exit 1
		fi
	fi

	fsize=`ls -l tr.apk | awk '{ print $5 }'`
	if [ $fsize -lt 1000 ]; then
		echo "============================================="
		echo "Error: tr.apk seems not valid"
		echo "Please try again"
		echo ""
		echo "Make sure your Antivirus is disabled"
		echo "============================================="
		rm tr.apk
		read tmpvar
		exit 1
	fi

	echo "============================================="
	echo "Extracting libexploit.so"
	echo "============================================="
	if [ "$OS" = "Darwin" ]; then
		unzip -j tr.apk lib/armeabi/libexploit.so > /dev/null
	else
		if [ "`whereis unzip`" = "unzip:" ]; then
			./unzip.linux -j tr.apk lib/armeabi/libexploit.so > /dev/null
		else
			unzip -j tr.apk lib/armeabi/libexploit.so > /dev/null
		fi
	fi

	if [ ! -f libexploit.so ]; then
		echo "Error extracting libexploit.so from tr.apk"
		echo "Press any key to quit"
		read tmpvar
		exit 1
	fi

	echo "OK!"
	rm tr.apk
	echo ""
fi


if [ "$OS" = "Linux" ]; then
	echo "It looks like you are running Linux"
	echo "Please make sure ia32-libs is installed if you get any errors"
	echo ""
fi

./${ADBBINARY} kill-server
./${ADBBINARY} start-server

echo "============================================="
echo "Waiting for Device, connect USB cable now..."
echo ""
echo "Make sure that you authorize the connection"
echo "if you get any message on the phone"
echo "============================================="
./${ADBBINARY} wait-for-device
echo "Device found!"
CDevices=`./${ADBBINARY} devices | wc -l`
if [ $CDevices -gt 3 ]; then
	echo "More than one device connected."

	availDevices=""
	CavailDevices=0
	
	adb_devices=`./${ADBBINARY} devices`
	Cadb_devices=`echo "$adb_devices" | wc -l`
	adb_devices=`echo "$adb_devices" | tail -$((Cadb_devices-1))`
	
	for line in `./${ADBBINARY} devices`; do
		case "$line" in
			"emulator"*)
				;;
			"List"|"of"|"devices"|"attached")
				;;
			"device")
				;;
			"")
				;;
			*)
				CurDev=`echo "$line" | cut -f1 | cut -d' ' -f1`
				CavailDevices=$((CavailDevices+1))
				availDevices="$availDevices$CurDev"'\n'
				;;
		esac
	done

	if [ $CavailDevices -eq 1 ]; then
		export ANDROID_SERIAL=`echo "$availDevices" | tr -d '\r\n'`
		echo "Using device $ANDROID_SERIAL since other is emulator.."
	else
		DevChosen=
		while ! "$DevChosen" -ne 0 > /dev/null 2>&1 && ! "$DevChosen" -eq 0 > /dev/null 2>&1; do
			echo ""
			echo "Please choose the connected device you would"
			echo "like to root. You can check under:"
			echo "Settings => About phone => Status => Serial number"
			echo ""
			echo "Available devices are:"
			CDevices=0
			echo "$availDevices" | while read -r line; do
				CDevices=$((CDevices+1))
				echo "$CDevices. $line"
			done
			echo "Please choose device [1 - $CDevices]:"
			read DevChosen
		done
		export ANDROID_SERIAL=`echo "$availDevices" | head -$DevChosen | tail -1`
		echo "Connecting to device $ANDROID_SERIAL"
	fi
fi

echo ""
echo "============================================="
echo "Getting device variables"
echo "============================================="
product_name=`./${ADBBINARY} shell "getprop ro.build.product"`
echo "Device model is $product_name"
firmware=`./${ADBBINARY} shell "getprop ro.build.id"`
echo "Firmware is $firmware"

echo ""
echo "============================================="
echo "Sending files"
echo "============================================="

./${ADBBINARY} push zxz.sh /data/local/tmp/zxz.sh
./${ADBBINARY} push installmount.sh /data/local/tmp
./${ADBBINARY} push writekmem /data/local/tmp
./${ADBBINARY} push findricaddr /data/local/tmp
./${ADBBINARY} push busybox /data/local/tmp
./${ADBBINARY} shell "chmod 777 /data/local/tmp/zxz.sh"
./${ADBBINARY} shell "chmod 777 /data/local/tmp/installmount.sh"
./${ADBBINARY} shell "chmod 777 /data/local/tmp/writekmem"
./${ADBBINARY} shell "chmod 777 /data/local/tmp/findricaddr"
./${ADBBINARY} shell "chmod 777 /data/local/tmp/busybox"

echo ""
echo "Copying kernel module..."
./${ADBBINARY} push "wp_mod.ko" /data/local/tmp
./${ADBBINARY} push "kernelmodule_patch.sh" /data/local/tmp
./${ADBBINARY} shell "chmod 777 /data/local/tmp/kernelmodule_patch.sh"
./${ADBBINARY} push "modulecrcpatch" /data/local/tmp
./${ADBBINARY} shell "chmod 777 /data/local/tmp/modulecrcpatch"
./${ADBBINARY} shell "/data/local/tmp/kernelmodule_patch.sh"

echo ""
echo "============================================="
echo "Loading geohot's towelroot (modified by zxz0O0)"
echo "============================================="

./${ADBBINARY} push towelzxperia_ert /data/local/tmp
./${ADBBINARY} push libexploit.so /data/local/tmp
./${ADBBINARY} shell "chmod 777 /data/local/tmp/towelzxperia_ert"

echo "============================================="
echo ""
echo "Waiting for towelroot to exploit..."
./${ADBBINARY} shell "/data/local/tmp/towelzxperia_ert"
echo "done"

echo ""
echo "Checking if device is rooted..."
sleep 1
#./${ADBBINARY} wait-for-device
isRooted=`./${ADBBINARY} shell "su -c ls -l" | tr -d '\r\n'`
if [ "$isRooted" = "/system/bin/sh: su: not found" ] || [ "$isRooted" = "" ]; then
	echo "Error: device not rooted"
	exit 1
fi

echo ""
echo "Device rooted."

echo ""
echo "============================================="
echo "Checking for Sony RIC"
echo "============================================="
SONYRIC=`./${ADBBINARY} shell "su -c /data/local/tmp/busybox grep 'sony_ric/enable' /init*.rc" | wc -l | tr -d '\r\n'`
 
if [ $SONYRIC -gt 0 ]; then
	echo "Sony RIC Service found."
	echo "Installing RIC kill script installmount.sh..."
	sleep 1
	./${ADBBINARY} wait-for-device
	./${ADBBINARY} shell "su -c /data/local/tmp/installmount.sh"
else
	echo "No Sony RIC Service found."
fi
echo ""
echo "Done. You can now unplug your device."
echo "Enjoy root!"
echo "============================================="

./${ADBBINARY} shell "rm /data/local/tmp/zxz.sh"
./${ADBBINARY} shell "rm /data/local/tmp/kernelmodule_patch.sh"
./${ADBBINARY} shell "rm /data/local/tmp/findricaddr"
./${ADBBINARY} shell "rm /data/local/tmp/installmount.sh"
./${ADBBINARY} shell "rm /data/local/tmp/towelzxperia_ert"
./${ADBBINARY} shell "rm /data/local/tmp/libzxploit.so"
./${ADBBINARY} shell "rm /data/local/tmp/libexploit.so"
./${ADBBINARY} kill-server

echo ""
echo "What to do next?"
echo "- Donate to the people involved"
echo "- Install SuperSU by Chainfire"
echo "- Install dualrecovery by [NUT]"
echo "- Backup TA partition"
echo ""
echo "Press any key to quit"
read tmpvar
exit 0