#!/system/bin/sh

installModule(){
	rm /data/local/tmp/ricaddr &> /dev/null
	rm /data/local/tmp/writekmem &> /dev/null
	if [ "`lsmod | grep wp_mod`" = "" ]; then
		insmod /data/local/tmp/wp_mod.ko
	fi

	return 0
}

touch /data/local/tmp/zxz_run

RICPATH=`ps | /data/local/tmp/busybox grep "bin/ric" | /data/local/tmp/busybox awk '{ print $NF }'`
if [ "$RICPATH" != "" ]; then
	mount -o remount,rw / && mv ${RICPATH} ${RICPATH}c && /data/local/tmp/busybox pkill -f ${RICPATH}
fi

kmem_exists=`ls /dev/kmem 2> /dev/null`
if [ "$kmem_exists" = "" ]; then
	touch /data/local/tmp/ricaddr
	chmod 777 /data/local/tmp/ricaddr

	findricaddr=`/data/local/tmp/findricaddr 2> /dev/null`
	if [ "$?" = "0" ]; then
		echo "$findricaddr" | /data/local/tmp/busybox tail -n1 | /data/local/tmp/busybox cut -d= -f2 > /data/local/tmp/ricaddr
	else
		echo 0 > /proc/sys/kernel/kptr_restrict
		kallsyms_RIC=`/data/local/tmp/busybox cat /proc/kallsyms | /data/local/tmp/busybox grep "sony_ric_enabled" | /data/local/tmp/busybox grep "T" | /data/local/tmp/busybox cut -d' ' -f1`
		RIC_dump=`dd if=/dev/kmem skip=$(( 0x$kallsyms_RIC )) bs=1 count=16 2> /dev/null | /data/local/tmp/busybox hexdump`
		echo -n `echo $RIC_dump | /data/local/tmp/busybox cut -d' ' -f9` > /data/local/tmp/ricaddr
		echo `echo $RIC_dump | /data/local/tmp/busybox cut -d' ' -f8` >> /data/local/tmp/ricaddr
	fi

	RIC_addr=`/data/local/tmp/busybox cat /data/local/tmp/ricaddr`
	if [ ${#RIC_addr} -gt 7 ]; then
		/data/local/tmp/writekmem $RIC_addr 0 &> /dev/null
	else
		installModule
	fi
else
	installModule
fi

mount -o remount,rw /system
exit