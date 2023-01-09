# factbid_poll
Node.js app that fetches tweets in the background, storing in mysql to be rendered by the php in factbid2
"pm2 start index.js" is going to start the background polling service, however it won't do anything until search_tweets is called
"curl -X POST http://localhost:3000/search_tweets" kicks it off fetching all tweets in the 'tweet' mysql table.
It first fetches the last tweet id from the tweet table and only gets new tweets since that one.  DELETE FROM tweet; will cause it to get all tweets.
It can only read 100 at a time, so it may loop repeatedly at first until it is has caught up.
Once it finishes, it calls the Mysql stored procedure process_tweets passing in the first tweet ID number, like this: CALL process_tweets(@first_tweet_id := 1);
That SP processes the new tweets and populates the hashtag, bid and claim tables, which is what the PHP front-end uses.
search_tweet needs to be called again after a waiting timeout to fetch new tweets.
"pm2 list" shows active by id and "pm2 stop [id]" stops the id

#steps to install
1: Put the code in a folder, such as: cd /opt; git clone https://github.com/aaronfactbid/factbid_poll.git
2: Run command "npm install"
3: Application code is configured to run on port number 3000, so make sure on server this post is open.
4: import the database backup file: tweets_by_hashtags.sql
5: Configure datbase credentials in ".env" file
6: Install pm2 using command "sudo npm install pm2 -g"
7: Start server by running command "sudo pm2 start index.js" from the directory with the code (/opt/factbid_poll)
8: Open POSTMAN and make POST call to url: http://yourwebsite.com:3000/search_tweets
9: To view logs run command "pm2 logs"
10: I then do crontab -e and add this to call every 10 minutes:
*/10 * * * * /opt/factbid_poll/update_tweets.sh &
11: I also add a database backup every 24 hours
mysqldump --quote-names --allow-keywords --add-drop-table -u aaron -pXXXX factbid > factbid.2023-01-07_11-54.dump

#might be necessary to update npm with:
npm cache clean -f
npm install -g n
sudo n stable