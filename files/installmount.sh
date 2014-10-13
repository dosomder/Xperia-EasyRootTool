#!/system/bin/sh

echo "#!/system/bin/sh" > /data/local/tmp/mount.sh

if [ -f /data/local/tmp/ricaddr ]; then
	echo "/data/local/tmp/writekmem `/data/local/tmp/busybox cat /data/local/tmp/ricaddr` 0 &> /dev/null" >> /data/local/tmp/mount.sh
	/data/local/tmp/writekmem `/data/local/tmp/busybox cat /data/local/tmp/ricaddr` 0 &> /dev/null
else
	echo 'mod_loaded=`lsmod | grep wp_mod`' >> /data/local/tmp/mount.sh
	echo 'if [ "$mod_loaded" = "" ]; then' >> /data/local/tmp/mount.sh
	echo '	if [ -f /system/lib/modules/wp_mod.ko ]; then' >> /data/local/tmp/mount.sh
	echo "		insmod /system/lib/modules/wp_mod.ko" >> /data/local/tmp/mount.sh
	echo "	else" >> /data/local/tmp/mount.sh
	echo "		insmod /data/local/tmp/wp_mod.ko" >> /data/local/tmp/mount.sh
	echo "	fi" >> /data/local/tmp/mount.sh
	echo "fi" >> /data/local/tmp/mount.sh
	mod_loaded=`lsmod | grep wp_mod`
	if [ "$mod_loaded" = "" ]; then
		if [ -f /system/lib/modules/wp_mod.ko ]; then
			insmod /system/lib/modules/wp_mod.ko
		else
			insmod /data/local/tmp/wp_mod.ko
		fi
	fi
fi

echo '/system/bin/stock/mount "$@"' >> /data/local/tmp/mount.sh

mount -o remount,rw /system
if [ ! -f /system/bin/stock/mount ]
then
	echo "Stock mount does not exist. Creating dir and link"
	mkdir /system/bin/stock
	chmod 755 /system/bin/stock
	ln -s /system/bin/toolbox /system/bin/stock/mount
fi
rm /system/bin/mount
cp /data/local/tmp/mount.sh /system/bin/mount
chmod 755 /system/bin/mount

cp /data/local/tmp/wp_mod.ko /system/lib/modules/wp_mod.ko
chmod 644 /system/lib/modules/wp_mod.ko

echo "Installing of mount.sh finished"
