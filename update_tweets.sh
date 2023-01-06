#!/bin/bash

dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "starting: $dt" >> /var/log/factbid/cronjob.log
curl -X POST "http://localhost:3000/search_tweets" -o /var/log/factbid/cronjob.log >> /var/log/factbid/cronjob.log
echo "ended $? : $dt" >> /var/log/factbid/cronjob.log
