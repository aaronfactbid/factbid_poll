#!/bin/bash

dt=$(date '+%d/%m/%Y %H:%M:%S');
echo -e "starting: $dt\n" >> /var/log/factbid/cronjob.log
curl -X POST "http://localhost:3000/search_tweets" >> /var/log/factbid/cronjob.log
retVal=$?
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo -e "ended $retVal : $dt\n" >> /var/log/factbid/cronjob.log
if [ $retVal -ne 0 ]; then
	echo "error"
fi
exit $retVal
