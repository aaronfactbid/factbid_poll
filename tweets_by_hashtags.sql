-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jan 05, 2023 at 09:20 PM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*Table structure for table `bid` */

CREATE TABLE `bid` (
  `id_bid` int(11) NOT NULL AUTO_INCREMENT,
  `id_hashtag` int(11) DEFAULT NULL,
  `id_tweet` int(11) DEFAULT NULL,
  `author_username` varchar(255) DEFAULT NULL,
  `author_id` varchar(50) DEFAULT NULL,
  `id_twitter` varchar(30) DEFAULT NULL,
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `currency` varchar(4) DEFAULT NULL,
  `amount` int(11) unsigned DEFAULT NULL,
  `sort` int(11) unsigned DEFAULT NULL,
  `exclude` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id_bid`),
  KEY `id_hashtag` (`id_hashtag`,`sort`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Table structure for table `claim` */

CREATE TABLE `claim` (
  `id_claim` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_hashtag` int(11) unsigned DEFAULT NULL,
  `id_tweet` int(11) DEFAULT NULL,
  `author_username` varchar(255) DEFAULT NULL,
  `author_id` varchar(30) DEFAULT NULL,
  `id_twitter` varchar(30) DEFAULT NULL,
  `created_ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `sort` int(11) DEFAULT NULL,
  `exclude` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id_claim`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Table structure for table `hashtag` */

CREATE TABLE `hashtag` (
  `id_hashtag` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `hashtag` varchar(50) NOT NULL,
  `id_tweet` int(11) unsigned DEFAULT NULL,
  `id_tweet_original` int(11) DEFAULT NULL COMMENT 'This is the original that was first added',
  `id_tweet_prior` int(11) DEFAULT NULL COMMENT 'When we change author with the a command this has the prior id',
  `id_process` int(11) unsigned DEFAULT NULL,
  `author_username` varchar(255) DEFAULT NULL,
  `bids` int(11) unsigned DEFAULT NULL,
  `total` int(11) unsigned DEFAULT NULL,
  `claims` int(11) unsigned DEFAULT NULL,
  `author_id` varchar(30) DEFAULT NULL,
  `id_twitter` varchar(30) DEFAULT NULL,
  `created_ts` timestamp NULL DEFAULT NULL,
  `title` text DEFAULT NULL,
  `category` char(1) DEFAULT NULL,
  `sort` int(11) unsigned DEFAULT NULL,
  `exclude` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id_hashtag`),
  UNIQUE KEY `hashtag` (`hashtag`),
  KEY `id_tweet` (`id_tweet`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Table structure for table `process` */

CREATE TABLE `process` (
  `id_process` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `started_ts` timestamp NULL DEFAULT NULL,
  `id_tweet_argument` int(11) DEFAULT NULL,
  `id_tweet_first` int(11) DEFAULT NULL,
  `id_tweet_last` int(11) DEFAULT NULL,
  `id_twitter_first` varchar(30) DEFAULT NULL,
  `id_hashtag_before` int(11) DEFAULT NULL,
  `id_hashtag_after` int(11) DEFAULT NULL,
  `tweet_last_ts` timestamp NULL DEFAULT NULL,
  `finished_ts` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id_process`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Table structure for table `tweet` */

CREATE TABLE `tweet` (
  `id_tweet` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `id_process` int(11) DEFAULT NULL,
  `id_twitter` varchar(30) DEFAULT NULL,
  `id_twitter_referenced` varchar(30) DEFAULT NULL,
  `id_tweet_referenced` int(11) unsigned DEFAULT NULL,
  `text` text DEFAULT NULL,
  `created_at` varchar(50) DEFAULT NULL,
  `created_ts` timestamp NULL DEFAULT NULL,
  `author_id` varchar(30) DEFAULT NULL,
  `conversation_id` varchar(30) DEFAULT NULL,
  `retweet_count` int(10) unsigned DEFAULT NULL,
  `reply_count` int(10) unsigned DEFAULT NULL,
  `like_count` int(10) unsigned DEFAULT NULL,
  `quote_count` int(10) unsigned DEFAULT NULL,
  `lang` varchar(3) DEFAULT NULL,
  `reply_settings` varchar(15) DEFAULT NULL,
  `author_name` varchar(255) DEFAULT NULL,
  `author_username` varchar(255) DEFAULT NULL,
  `author_created_at` varchar(50) DEFAULT NULL,
  `author_verified` tinyint(1) DEFAULT NULL,
  `author_followers_count` int(10) unsigned DEFAULT NULL,
  `author_following_count` int(10) unsigned DEFAULT NULL,
  `author_tweet_count` int(10) unsigned DEFAULT NULL,
  `author_listed_count` int(10) unsigned DEFAULT NULL,
  `currency` varchar(3) DEFAULT NULL,
  `amount` int(11) DEFAULT NULL,
  `amount_usd` int(11) DEFAULT NULL,
  `hashtag1` varchar(60) DEFAULT NULL,
  `hashtag2` varchar(60) DEFAULT NULL,
  `hashtag3` varchar(60) DEFAULT NULL,
  `hashtag4` varchar(60) DEFAULT NULL,
  `hashtag5` varchar(60) DEFAULT NULL,
  `id_hashtag1` int(11) unsigned DEFAULT NULL,
  `id_hashtag2` int(11) unsigned DEFAULT NULL,
  `id_hashtag3` int(11) unsigned DEFAULT NULL,
  `id_hashtag4` int(11) unsigned DEFAULT NULL,
  `id_hashtag5` int(11) unsigned DEFAULT NULL,
  `id_tweet_replaced` int(11) unsigned DEFAULT NULL,
  `is_bid` tinyint(1) DEFAULT 0,
  `lastchar` char(1) DEFAULT NULL,
  `actionchar` char(1) DEFAULT NULL,
  `tweet_time` varchar(20) NOT NULL,
  PRIMARY KEY (`id_tweet`),
  KEY `hashtag1` (`hashtag1`),
  KEY `hashtag2` (`hashtag2`),
  KEY `hashtag3` (`hashtag3`),
  KEY `hashtag4` (`hashtag4`),
  KEY `hashtag5` (`hashtag5`),
  KEY `id_process` (`id_process`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `currency` (
  `currency` varchar(3) NOT NULL,
  `value_usd` int(11) DEFAULT NULL,
  PRIMARY KEY (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `currency` */

insert  into `currency`(`currency`,`value_usd`) values ('$',100);
insert  into `currency`(`currency`,`value_usd`) values ('£',121);
insert  into `currency`(`currency`,`value_usd`) values ('€',107);

DELIMITER $$

USE `factbid`$$

DROP PROCEDURE IF EXISTS `process_tweets`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `process_tweets`(IN `first_tweet_id` INT(11))
BEGIN
	/* This will be called with the id of the first tweet to process, like: CALL process_tweets(@first_tweet_id := 5); */
	/* log the start */
	INSERT INTO `process` (started_ts,id_tweet_argument) VALUES(NOW(),@first_tweet_id);
	SET @id_process = LAST_INSERT_ID();

	/* general cleanup of the new tweets */
	UPDATE tweet SET id_process=@id_process WHERE `id_tweet`>=@first_tweet_id;
	UPDATE tweet SET created_ts=FROM_UNIXTIME(tweet_time/1000) WHERE `id_process`=@id_process;
	UPDATE tweet JOIN currency ON tweet.currency=currency.currency SET amount_usd=CAST(tweet.amount*value_usd/100 AS UNSIGNED INT) WHERE tweet.currency IS NOT NULL AND amount IS NOT NULL AND `id_process`=@id_process;
	UPDATE tweet SET lastchar=NULL WHERE lastchar='' AND `id_process`=@id_process;
	UPDATE tweet SET `hashtag1` = NULL WHERE `hashtag1` IS NOT NULL AND `hashtag1`='' AND `id_process`=@id_process;
	UPDATE tweet SET `hashtag2` = NULL WHERE `hashtag2` IS NOT NULL AND `hashtag2`='' AND `id_process`=@id_process;
	UPDATE tweet SET `hashtag3` = NULL WHERE `hashtag3` IS NOT NULL AND `hashtag3`='' AND `id_process`=@id_process;
	UPDATE tweet SET `hashtag4` = NULL WHERE `hashtag4` IS NOT NULL AND `hashtag4`='' AND `id_process`=@id_process;
	UPDATE tweet SET `hashtag5` = NULL WHERE `hashtag5` IS NOT NULL AND `hashtag5`='' AND `id_process`=@id_process;
	UPDATE tweet SET `actionchar` = 'a' WHERE `text` LIKE '%*a*%' AND `id_process`=@id_process;
	UPDATE tweet SET `actionchar` = 'd' WHERE `text` LIKE '%*d*%' AND `id_process`=@id_process;
	UPDATE tweet SET `actionchar` = 't' WHERE `text` LIKE '%*t*%' AND `id_process`=@id_process;
	UPDATE `process` SET id_tweet_first=(SELECT id_tweet FROM tweet WHERE id_process=@id_process ORDER BY id_tweet ASC LIMIT 1) WHERE id_process=@id_process;
	UPDATE `process` SET id_tweet_last=(SELECT id_tweet FROM tweet WHERE id_process=@id_process ORDER BY id_tweet DESC LIMIT 1) WHERE id_process=@id_process;
	UPDATE `process` SET id_hashtag_before=(SELECT id_hashtag FROM hashtag ORDER BY id_hashtag DESC LIMIT 1) WHERE id_process=@id_process;
	UPDATE `process` SET id_twitter_first=(SELECT id_twitter FROM tweet WHERE id_tweet=@first_tweet_id) WHERE id_process=@id_process;
	UPDATE `process` SET tweet_last_ts=(SELECT MAX(created_ts) FROM tweet WHERE id_process=@id_process) WHERE id_process=@id_process;

	/* if the actionchar is an 'a' this tweet may be trying to change the original author to the referenced tweet, so match up the id's referenced */
	UPDATE tweet SET id_twitter_referenced=NULL WHERE id_twitter_referenced='' AND `id_process`=@id_process;
	UPDATE tweet JOIN tweet AS tweet_referenced ON tweet.id_twitter_referenced=tweet_referenced.id_twitter SET tweet.id_tweet_referenced=tweet_referenced.id_tweet WHERE tweet.actionchar='a' AND `tweet`.`id_process`=@id_process;

	/* set ID's for existing hashtags */
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag1` SET `id_hashtag1` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_process`=@id_process;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag2` SET `id_hashtag2` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_process`=@id_process;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag3` SET `id_hashtag3` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_process`=@id_process;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag4` SET `id_hashtag4` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_process`=@id_process;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag5` SET `id_hashtag5` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_process`=@id_process;

	/* add any new hashtags ignoring duplicates */
	UPDATE `process` SET id_hashtag_before = (SELECT id_hashtag FROM hashtag ORDER BY id_hashtag DESC LIMIT 1) WHERE `id_process`=@id_process;
	INSERT IGNORE INTO `hashtag` (`hashtag`,`id_process`) SELECT `hashtag1`,@id_process FROM `tweet` WHERE `tweet`.`id_process`=@id_process AND `hashtag1` IS NOT NULL AND `hashtag1`<>'';
	INSERT IGNORE INTO `hashtag` (`hashtag`,`id_process`) SELECT `hashtag2`,@id_process FROM `tweet` WHERE `tweet`.`id_process`=@id_process AND `hashtag1` IS NOT NULL AND `hashtag2`<>'';
	INSERT IGNORE INTO `hashtag` (`hashtag`,`id_process`) SELECT `hashtag3`,@id_process FROM `tweet` WHERE `tweet`.`id_process`=@id_process AND `hashtag1` IS NOT NULL AND `hashtag3`<>'';
	INSERT IGNORE INTO `hashtag` (`hashtag`,`id_process`) SELECT `hashtag4`,@id_process FROM `tweet` WHERE `tweet`.`id_process`=@id_process AND `hashtag1` IS NOT NULL AND `hashtag4`<>'';
	INSERT IGNORE INTO `hashtag` (`hashtag`,`id_process`) SELECT `hashtag5`,@id_process FROM `tweet` WHERE `tweet`.`id_process`=@id_process AND `hashtag1` IS NOT NULL AND `hashtag5`<>'';
	UPDATE `process` SET id_hashtag_after = (SELECT id_hashtag FROM hashtag ORDER BY id_hashtag DESC LIMIT 1) WHERE `id_process`=@id_process;

	/* set ID's for new hashtags */
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag1` SET `id_hashtag1` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_process`=@id_process;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag2` SET `id_hashtag2` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_process`=@id_process;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag3` SET `id_hashtag3` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_process`=@id_process;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag4` SET `id_hashtag4` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_process`=@id_process;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag5` SET `id_hashtag5` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_process`=@id_process;

	/* since the new hashtags are in 5 columns, consolidate them into 1 temporary table */
	DROP TABLE IF EXISTS `tweet_tmp`;
	CREATE TABLE `tweet_tmp` (
	`id_tweet` INT(11),
	`id_tweet_referenced` INT(11),
	`id_tweet_newauthor` INT(11),
	`id_hashtag` INT(11),
	`id_twitter` VARCHAR(30),
	`author_id` VARCHAR(30),
	`author_username` VARCHAR(255),
	`created_ts` TIMESTAMP,
	`currency` VARCHAR(4),
	`amount` INT(11),
	`is_bid` TINYINT(1),
	`actionchar` CHAR(1),
	KEY `id_hashtag` (`id_hashtag`)
	) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

	INSERT INTO `tweet_tmp` (`id_tweet`,`id_tweet_referenced`,`id_hashtag`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `actionchar` ) SELECT `id_tweet`,`id_tweet_referenced`,`id_hashtag1`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `actionchar`  FROM `tweet` WHERE `tweet`.`id_process`=@id_process AND `id_hashtag1` IS NOT NULL;
	INSERT INTO `tweet_tmp` (`id_tweet`,`id_tweet_referenced`,`id_hashtag`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `actionchar` ) SELECT `id_tweet`,`id_tweet_referenced`,`id_hashtag2`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `actionchar`  FROM `tweet` WHERE `tweet`.`id_process`=@id_process AND `id_hashtag2` IS NOT NULL;
	INSERT INTO `tweet_tmp` (`id_tweet`,`id_tweet_referenced`,`id_hashtag`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `actionchar` ) SELECT `id_tweet`,`id_tweet_referenced`,`id_hashtag3`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `actionchar`  FROM `tweet` WHERE `tweet`.`id_process`=@id_process AND `id_hashtag3` IS NOT NULL;
	INSERT INTO `tweet_tmp` (`id_tweet`,`id_tweet_referenced`,`id_hashtag`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `actionchar` ) SELECT `id_tweet`,`id_tweet_referenced`,`id_hashtag4`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `actionchar`  FROM `tweet` WHERE `tweet`.`id_process`=@id_process AND `id_hashtag4` IS NOT NULL;
	INSERT INTO `tweet_tmp` (`id_tweet`,`id_tweet_referenced`,`id_hashtag`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `actionchar` ) SELECT `id_tweet`,`id_tweet_referenced`,`id_hashtag5`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `actionchar`  FROM `tweet` WHERE `tweet`.`id_process`=@id_process AND `id_hashtag5` IS NOT NULL;

	/* The first new tweet ( MIN(id_tweet) ) should be the 'author' that is referenced in the hashtag */
	UPDATE `hashtag` JOIN 
	(SELECT MIN(id_tweet) AS id_tweet_min,id_hashtag FROM tweet_tmp GROUP BY id_hashtag) AS tweet_new ON `hashtag`.`id_hashtag`=`tweet_new`.`id_hashtag`
	SET `hashtag`.`id_tweet`=`tweet_new`.`id_tweet_min`,`hashtag`.`id_tweet_original`=`tweet_new`.`id_tweet_min`  WHERE `hashtag`.`id_tweet` IS NULL;

	/* Update the rest of the data in hashtag to point to it */
	UPDATE `hashtag` JOIN `tweet` ON `hashtag`.`id_tweet`=`tweet`.`id_tweet`
	SET `hashtag`.`id_twitter`=`tweet`.`id_twitter`,`hashtag`.`author_id`=`tweet`.`author_id`,`hashtag`.`author_username`=`tweet`.`author_username`,`hashtag`.`created_ts`=`tweet`.`created_ts`,`hashtag`.`title`=`tweet`.`text`
	WHERE `hashtag`.`id_process`=@id_process ;

	/* all new tweets ending with 't' means if it's the same author we need to update and point to this new tweet */
	UPDATE hashtag JOIN
	(SELECT MAX(id_tweet) AS id_tweet,id_hashtag,author_id FROM tweet_tmp WHERE actionchar='t' GROUP BY id_hashtag,author_id) AS tweets_update
		ON hashtag.id_hashtag=tweets_update.id_hashtag AND hashtag.author_id=tweets_update.author_id
	JOIN tweet ON tweet.id_tweet=tweets_update.id_tweet
	SET hashtag.id_tweet=tweet.id_tweet,hashtag.id_twitter=tweet.id_twitter;

	/* update changes to author, first set id_tweet_newauthor where there's a valid change from one author to another, then update the hashtag table */
	UPDATE tweet_tmp JOIN tweet ON tweet_tmp.id_tweet_referenced=tweet.id_tweet SET tweet_tmp.id_tweet_newauthor=tweet.id_tweet WHERE tweet_tmp.id_tweet_referenced IS NOT NULL AND (`tweet_tmp`.id_hashtag=`tweet`.`id_hashtag1` OR `tweet_tmp`.id_hashtag=`tweet`.`id_hashtag2` OR `tweet_tmp`.id_hashtag=`tweet`.`id_hashtag3` OR `tweet_tmp`.id_hashtag=`tweet`.`id_hashtag4` OR `tweet_tmp`.id_hashtag=`tweet`.`id_hashtag5`);

	UPDATE hashtag
	JOIN tweet_tmp ON tweet_tmp.id_hashtag=hashtag.id_hashtag
	JOIN tweet ON tweet_tmp.id_tweet_newauthor=tweet.id_tweet
	SET `hashtag`.id_tweet_prior=hashtag.id_tweet, hashtag.id_tweet=tweet.id_tweet,
	hashtag.author_username=tweet.author_name, hashtag.author_id=tweet.author_id, hashtag.id_twitter=tweet.id_twitter, hashtag.title=tweet.text
	WHERE tweet_tmp.id_tweet_newauthor IS NOT NULL;

	
	/* NEED TO ADD THIS ONCE THE ID_TWEET_REFERENCED IS ADDED */

	/* all new tweets ending with 'd' means if it's the same author we need to update the description in the title field */
	UPDATE hashtag JOIN
	(SELECT MAX(id_tweet) AS id_tweet,id_hashtag,author_id FROM tweet_tmp WHERE actionchar='d' GROUP BY id_hashtag,author_id) AS tweets_update
		ON hashtag.id_hashtag=tweets_update.id_hashtag AND hashtag.author_id=tweets_update.author_id
	JOIN tweet ON tweet.id_tweet=tweets_update.id_tweet
	SET hashtag.title=REPLACE( `tweet`.`text`, '*d*', '' );
	
	/* add the new bids */
	INSERT INTO `bid` (`id_hashtag`,`id_tweet`,`author_username`,`author_id`,`id_twitter`,`created_ts`,`currency`,`amount`)
	SELECT `id_hashtag`,`id_tweet`,`author_username`,`author_id`,`id_twitter`,`created_ts`,`currency`,`amount`
	FROM `tweet_tmp` WHERE is_bid=1 AND currency IS NOT NULL AND amount IS NOT NULL;

	/* add the new claims */
	INSERT INTO `claim` (`id_hashtag`,`id_tweet`,`author_username`,`author_id`,`id_twitter`,`created_ts`)
	SELECT `id_hashtag`,`id_tweet`,`author_username`,`author_id`,`id_twitter`,`created_ts`
	FROM `tweet_tmp` WHERE is_bid=0;
	
	/* set any bids that have been superceded to exclude = 1*/
	UPDATE `bid` SET `exclude`=0;
	UPDATE `bid` JOIN
	(SELECT MAX(id_tweet) AS id_tweet,id_hashtag,author_id FROM bid GROUP BY id_hashtag,author_id) AS bid_latest
	ON bid.id_hashtag=bid_latest.id_hashtag AND bid.author_id=bid_latest.author_id
	SET `exclude`=1
	WHERE `bid`.`id_tweet`<>`bid_latest`.`id_tweet`;

	/* update the bid totals */
	UPDATE `hashtag` 
	JOIN 
	(SELECT `id_hashtag`, COUNT(`id_bid`) AS bid_count,SUM(`amount`) AS bid_total FROM `bid` WHERE `exclude`=0 AND `currency` IS NOT NULL GROUP BY `id_hashtag`) AS bid_total
	ON `bid_total`.`id_hashtag`=`hashtag`.`id_hashtag`
	SET `hashtag`.`bids`=bid_count,`hashtag`.`total`=bid_total;
	
	/* update the claim totals */
	UPDATE `hashtag` 
	JOIN 
	(SELECT `id_hashtag`, COUNT(`id_claim`) AS claim_count FROM `claim` WHERE `exclude`=0 IS NOT NULL GROUP BY `id_hashtag`) AS claim_total
	ON `claim_total`.`id_hashtag`=`hashtag`.`id_hashtag`
	SET `hashtag`.`claims`=claim_count;
	
	/* set the sort order to show hashtags.  For the moment just alphabetical */
	UPDATE hashtag SET sort=NULL;
	UPDATE hashtag, (SELECT @n := 1000) m SET hashtag.sort = @n := @n + 1 WHERE sort IS NULL ORDER BY hashtag.hashtag;

	/* set the sort order to show bids.  For the moment just reverse chronological */
	UPDATE bid SET sort=NULL;
	UPDATE bid, (SELECT @n := 1000) m SET bid.sort = @n := @n + 1 WHERE sort IS NULL ORDER BY bid.id_tweet DESC;

	/* cleanup */
	UPDATE `process` SET id_hashtag_after=(SELECT id_hashtag FROM hashtag ORDER BY id_hashtag DESC LIMIT 1) WHERE id_process=@id_process;

	/* close out this */
	UPDATE `process` SET finished_ts=NOW() WHERE `id_process`=@id_process ;	
END$$

DELIMITER ;


/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
