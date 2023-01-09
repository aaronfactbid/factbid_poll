#!/bin/bash

dt=$(date '+%d/%m/%Y %H:%M:%S');
echo -e "starting: $dt\n" >> /var/log/factbid/cronjob.log
curl -X POST "http://localhost:3000/search_tweets" >> /var/log/factbid/cronjob.log
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo -e "ended $? : $dt\n" >> /var/log/factbid/cronjob.log
