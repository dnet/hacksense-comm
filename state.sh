#!/bin/sh
if [ "$1" = "get" ]; then
	STATE=`wget "http://vsza.hu/sense.php?d=get" -q -O -`
	echo "Wget'd state: $STATE"
	exit $STATE
else
	wget "http://vsza.hu/sense.php?d=$1" -q
fi
