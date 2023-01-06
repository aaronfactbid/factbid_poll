const express = require("express");
const http = require('http')
const mysql = require('mysql');
const { TwitterApi }  = require('twitter-api-v2');
const axios = require('axios');
const moment = require('moment-timezone')

require('dotenv').config()
const config = require('./config.json');

const app = express();
const session = require('express-session')({
	secret : "@#$%^&*(LKJLKSALYUQWEMJQWN<MNQDKLJHSALKJDHAUISDIUDYSASHDAM<SD",
	saveUninitialized : false,
	resave : false
})
app.use(session);

const twitterClient = new TwitterApi(config.twitter_bearer_token);

app.post("/search_tweets", async (req, res) =>  {
    let response = {
        status: 'error',
        message: 'Something went wrong, please try again after sometime.',
        data: {}
    }
    try {
        let firstTweetId = '';
        let dbConn = mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME,
            charset: 'utf8mb4'
        });
        dbConn.connect(async function(e) {
            if(!e){
                console.log(`Database connection start`);

                console.log('Checking last Tweet in database.')
                let sql = "SELECT * FROM tweet ORDER BY tweet_time DESC LIMIT 1";
                dbConn.query(sql, async (e, rows) => {
                    if (!e){
                        
                        let lastTweetId = '';
                        if(rows.length > 0){
                            lastTweetId = rows[0].id_twitter;
                            console.log('Last Tweet record found in database with ID: ' + rows[0].id_twitter);
                        }
                        else{
                            console.log('No last Tweet record found in database');
                        }

                        let result = await fnProcessTweets(dbConn, firstTweetId, lastTweetId, 'FIRST_CALL');
                        if(result.firstTweetId){
                            fnProcessStoredProcedure(result.firstTweetId, dbConn)
                        }
                        if(result.allHashtagsData){
                            fnProcessCloudflare(result.allHashtagsData)
                        }                        

                        response.status = 'success';
                        response.message = '';
                        res.send(response);
                    }
                    else{
                        console.log('Error --> SELECT * FROM tweets --> failed');
                        res.send(response);
                    }
                });
            }
            else{
                console.log('Server error --> database connection failed.');
                res.send(response);
            }
        });
        dbConn.on(`end`, (err) => {
            console.log(`Database connection end`);
        });
    }
    catch (e) {
        console.log('Server error --> fnSearchTweets --> e', e)
        res.send(response)
    }
});
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
async function fnProcessTweets(dbConn, firstTweetId, lastTweetId, nextToken = ''){
    await sleep(1000);
    return new Promise(async function(resolve, reject){
        let allHashtagsData = [];
        if(lastTweetId != '' || nextToken != ''){
            let params = {
                query: '(#' + config.hashtag_bid + ' OR #' + config.hashtag_claim + ') -is:retweet',
                expansions: [
                    'author_id',
                    'referenced_tweets.id'
                ],
                "tweet.fields": [
                    "author_id",
                    "conversation_id",
                    "created_at",
                    "lang",
                    "public_metrics",
                    "reply_settings",
                    "entities"
                ],
                "user.fields": [
                    "name",
                    "username",
                    "created_at",
                    "public_metrics",
                    "verified"
                ],
                max_results: 100
            }
            if(lastTweetId)
                params.since_id = lastTweetId
            
            if(nextToken && nextToken != 'FIRST_CALL')
                params.next_token = nextToken;

            if(nextToken == 'FIRST_CALL')
                console.log('Making first Twitter API call.')
            else
                console.log('Making Twitter API call with nextToken: ', nextToken)
            

            const result = await twitterClient.v2.get('tweets/search/recent', params);
            
            let tweets = (result && result.data) ? result.data : [];
            let users = (result && result.includes?.users) ? result.includes.users : [];
            nextToken = (result && result.meta?.next_token) ? result.meta.next_token : '';
            
            if(users.length > 0){
                let temp = {};
                let uCount = users.length;
                for (let i = 0; i < uCount; i++) {
                    temp[users[i].id] = users[i];
                }
                users = temp;
            }
            
            let tCount = tweets.length;
            let proccessedTweets = 0;
            console.log('Tweets found: ', tCount)
            if(tCount > 0){
                for (let i = 0; i < tCount; i++) {
                    let tweetData = tweets[i];

                    let tweetId = tweetData.id;
                    let authorId = tweetData.author_id;

                    let sql = "SELECT * FROM tweet WHERE id_twitter = '" + tweetId + "'";
                    dbConn.query(sql, async (e, rows) => {
                        if (!e){
                            if(!rows || rows.length == 0){
                            
                                let userData = {}
                                if(users[authorId]){
                                    userData = users[authorId]
                                }

                                let tweetText = tweetData.text                                        
                                let regEx = new RegExp('\n', 'g');
                                tweetText = tweetText.replace(regEx, ' ');

                                let amount = 0;
                                let currency = '';
                                config.currency_symbols.map((currency_symbol) => {
                                    let n = tweetText.indexOf(currency_symbol);
                                    if( n != -1){
                                        currency = currency_symbol;
                                        let pos = tweetText.indexOf(' ', n);
                                        if(pos != -1){
                                            amount = (tweetText.substring(n, pos)).replace(currency_symbol, '');
                                        }
                                        else{
                                            amount = (tweetText.substring(n)).replace(currency_symbol, '');
                                        }
                                        amount = parseInt(amount);
                                        amount = (isNaN(amount)) ? 0 : amount; 
                                    }
                                })

                                let lastchar = ((tweetText[tweetText.length - 2]) == ' ') ? tweetText[tweetText.length - 1] : '';
                                let is_bid = (tweetText.search(new RegExp(config.hashtag_bid, "i")) != -1) ? 1 : 0;

                                let h = 0;
                                let hashtags = ['','','','',''];
                                if(tweetData.entities?.hashtags?.length > 0){
                                    let tags = tweetData.entities.hashtags;
                                    for (let t = 0; t < tags.length; t++) {
                                        if( (tags[t].tag.toLowerCase() != config.hashtag_bid.toLowerCase()) && (tags[t].tag.toLowerCase() != config.hashtag_claim.toLowerCase()) ){
                                            hashtags[h] = tags[t].tag;
                                            h++;
                                        }
                                    }
                                    allHashtagsData = allHashtagsData.concat(hashtags)
                                }

                                let referencedId = '';
                                if(tweetData.referenced_tweets?.length > 0){
                                    for (let r = 0; r < tweetData.referenced_tweets.length; r++) {
                                        referencedId = tweetData.referenced_tweets[r].id;                                        
                                    }
                                } 

                                let created_at = tweetData.created_at || '';
                                let author_id = tweetData.author_id || '';
                                let conversation_id = tweetData.conversation_id || '';
                                let retweet_count = tweetData.public_metrics.retweet_count || 0;
                                let reply_count = tweetData.public_metrics.reply_count || 0;
                                let like_count = tweetData.public_metrics.like_count || 0;
                                let quote_count = tweetData.public_metrics.quote_count || 0;
                                let lang = tweetData.lang || '';
                                let reply_settings = tweetData.reply_settings || '';
                                
                                let author_name = userData.name || '';
                                let author_username = userData.username || '';
                                let author_created_at = userData.created_at || '';
                                let author_verified = userData.verified || false;
                                let author_followers_count = userData.public_metrics.followers_count || 0;
                                let author_following_count = userData.public_metrics.following_count || 0;
                                let author_tweet_count = userData.public_metrics.tweet_count || 0;
                                let author_listed_count = userData.public_metrics.listed_count || 0;

                                let tweet_time = moment(created_at).format('x');
                                
                                let tweet = {
                                    id_twitter: tweetData.id,
                                    id_twitter_referenced: referencedId,
                                    text: tweetData.text,
                                    created_at,
                                    author_id,
                                    conversation_id,
                                    retweet_count,
                                    reply_count,
                                    like_count,
                                    quote_count,
                                    lang,
                                    reply_settings,
                                    author_name,
                                    author_username,
                                    author_created_at,
                                    author_verified,
                                    author_followers_count,
                                    author_following_count,
                                    author_tweet_count,
                                    author_listed_count,
                                    currency,
                                    amount,
                                    hashtag1: hashtags[0],
                                    hashtag2: hashtags[1],
                                    hashtag3: hashtags[2],
                                    hashtag4: hashtags[3],
                                    hashtag5: hashtags[4],
                                    is_bid,
                                    lastchar,
                                    tweet_time
                                }
                                let query = "INSERT INTO tweet SET ?";
                                dbConn.query(query, [tweet], async (e, rows) => {
                                    if (!e){
                                        if(firstTweetId == ''){
                                            firstTweetId = (rows.insertId) ? rows.insertId : false;
                                        }
                                    }
                                    else{
                                        console.log('Error in saving Tweet in database: Tweet ID: ', tweetData.id, e);
                                    }
                                    
                                    proccessedTweets++;
                                    if(proccessedTweets == tCount){
                                        let result = await fnProcessTweets(dbConn, firstTweetId, '', nextToken);
                                        if(result.allHashtagsData?.length > 0){
                                            allHashtagsData = allHashtagsData.concat(result.allHashtagsData);
                                        }
                                        resolve({allHashtagsData, firstTweetId: result.firstTweetId});
                                    }
                                });
                            }
                            else{
                                proccessedTweets++;
                                if(proccessedTweets == tCount){
                                    let result = await fnProcessTweets(dbConn, firstTweetId, '', nextToken);
                                    if(result.allHashtagsData?.length > 0){
                                        allHashtagsData = allHashtagsData.concat(result.allHashtagsData);
                                    }
                                    resolve({allHashtagsData, firstTweetId: result.firstTweetId});
                                }
                            }
                        }
                        else{
                            proccessedTweets++;
                            if(proccessedTweets == tCount){
                                let result = await fnProcessTweets(dbConn, firstTweetId, '', nextToken);
                                if(result.allHashtagsData?.length > 0){
                                    allHashtagsData = allHashtagsData.concat(result.allHashtagsData);
                                }
                                resolve({allHashtagsData, firstTweetId: result.firstTweetId});
                            }
                        }
                    })
                }
            }
            else{
                resolve({allHashtagsData, firstTweetId: result.firstTweetId});
            }
        }
        else{
            resolve({allHashtagsData, firstTweetId });
        }
    })
}
async function fnProcessStoredProcedure (firstTweetId, dbConn){
    if(firstTweetId){
        console.log('Calling stored procedure');
        dbConn.query('CALL process_tweets(' + firstTweetId + ');', async (e, rows) => {
            if(e){
                console.log('Error in processing stored procedure', e);
            }
            dbConn.end();
        });
    }
}
async function fnProcessCloudflare(hashtags){
    if(hashtags.length > 0){
        hashtags = hashtags.filter((v, i, a) => (v != '' && a.indexOf(v) === i) ); //filter and return only unique hashtag values 
        hashtags = hashtags.map((hashtag) => { return 'factbid.org/' + hashtag})
        console.log('Making API calls to Cloudflare for total ' + hashtags.length + ' hashtags')
        
        let chunkSize = 30; //In one API request cloudflare is allowing only 30 files or prefixes values
        for (let i = 0; i < hashtags.length; i += chunkSize) {
            let urls = hashtags.slice(i, i + chunkSize); //this will get the batch of 30 urls with hashtags from main array
            
            //make api call to cloudflare
            axios({
                method: 'post',
                url: 'https://api.cloudflare.com/client/v4/zones/' + config.cloudflare_zone_id + '/purge_cache',
                headers: {
                    'X-Auth-Email': config.cloudflare_email, 
                    'X-Auth-Key': config.cloudflare_key, 
                    'Content-Type': 'application/json', 
                },
                data : JSON.stringify({
                    file: urls
                    //prefixes: urls
                })
            })
            .then(function (response) {
                //console.log(response.data);
            })
            .catch(function (error) {
                console.log('Error in Cloudflare API: ', error);
            });
            await sleep(1000);
        }
    }
}

app.use('*', function(req, res){
    console.log('Not Found: ', req.originalUrl);
    res.status(404).send('Page not found');
});

const port = process.env.APP_PORT;
app.set('port', port)
const server = http.createServer(app, session)
server.listen(port, () => {
    console.log('Server is running at port ' + port);
    
});
server.on('error', (error) => {
    if(error.syscall != 'listen'){
        throw error
    }
    var bind = typeof port === 'string' ? 'Pipe ' + port : 'Port ' + port

    switch(error.code){
        case 'EACCES':
            console.log(bind + 'require elevated privileges.')
            process.exit(1)
            break;
        case 'EADDRINUSE':
            console.log(bind + ' is already in use.')
            process.exit(1)
            break;
        default:
            throw error
    }
});