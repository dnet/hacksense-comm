#!/bin/sh
if [ "$1" = "get" ]; then
	STATE=`wget "http://vsza.hu/hacksense/status.csv" -q -O - |sed -e "s/^[^;]*;[^;]*;//" -e "s/;.*$//"`
	echo "Wget'd state: $STATE"
	exit $STATE
else
	UUID=`cat /proc/sys/kernel/random/uuid`
	wget "http://vsza.hu/hacksense/submit/`./signer $UUID!$1`" -q -O -
fi
