#!/bin/sh
if [ "$1" = "get" ]; then
	STATE=`wget "http://vsza.hu/hacksense/status.csv" -q -O - |sed -e "s/^[^;]*;[^;]*;//" -e "s/;.*$//"`
	echo "Wget'd state: $STATE"
	exit $STATE
else
	wget "http://vsza.hu/hacksense/submit/`./signer $1`" -q
fi
