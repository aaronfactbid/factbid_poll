# factbid_poll
Node.js app that fetches tweets in the background, storing in mysql to be rendered by the php in factbid2
"pm2 start index.js" is going to start the background polling service, however it won't do anything until search_tweets is called
"curl -X POST http://localhost:3000/search_tweet" kicks it off fetching all tweets in the 'tweet' mysql table.
It can only read 100 at a time, so it may loop repeatedly at first until it is has caught up.
Once it finishes, it calls the Mysql stored procedure process_tweets passing in the first tweet ID number
That SP processes the new tweets and populates the hashtag, bid and claim tables, which is what the PHP front-end uses.
search_tweet needs to be called again after a waiting timeout to fetch new tweets


#steps to install
Step 1: Extract the zip file and upload in any folder on server
Step 2: Run command "npm install"
Step 3: Application code is configured to run on port number 3000, so make sure on server this post is open.
Step 4: import the database backup file: tweets_by_hashtags.sql
Step 5: Configure datbase credentials in ".env" file
Step 6: Install pm2 using command "sudo npm install pm2 -g"
Step 7: Start server by running command "sudo pm2 start index.js"
Step 8: Open POSTMAN and make POST call to url: http://yourwebsite.com:3000/search_tweets  
Step 9: To view logs run command "pm2 logs"

#might be necessary to update npm with:
npm cache clean -f
npm install -g n
sudo n stable