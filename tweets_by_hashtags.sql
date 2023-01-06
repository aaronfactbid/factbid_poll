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


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `tweets_by_hashtags`
--

DELIMITER $$

DROP PROCEDURE IF EXISTS `process_tweets`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `process_tweets`(IN `first_tweet_id` INT(11))
BEGIN
	/* This will be called with the id of the first tweet to process, like: CALL process_tweets(@first_tweet_id := 5); */
	/* log the start */
	INSERT INTO `process` (started_ts,id_tweet_argument) VALUES(NOW(),@first_tweet_id);
	SET @id_process = LAST_INSERT_ID();

	/* general cleanup of the new tweets */
	UPDATE tweet SET created_ts=FROM_UNIXTIME(tweet_time/1000) WHERE `id_tweet`>=@first_tweet_id;
	UPDATE tweet SET currency=NULL WHERE currency='' AND `id_tweet`>=@first_tweet_id;
	UPDATE tweet SET `hashtag1` = NULL WHERE `hashtag1` IS NOT NULL AND `hashtag1`='' AND `id_tweet`>=@first_tweet_id;
	UPDATE tweet SET `hashtag2` = NULL WHERE `hashtag2` IS NOT NULL AND `hashtag2`='' AND `id_tweet`>=@first_tweet_id;
	UPDATE tweet SET `hashtag3` = NULL WHERE `hashtag3` IS NOT NULL AND `hashtag3`='' AND `id_tweet`>=@first_tweet_id;
	UPDATE tweet SET `hashtag4` = NULL WHERE `hashtag4` IS NOT NULL AND `hashtag4`='' AND `id_tweet`>=@first_tweet_id;
	UPDATE tweet SET `hashtag5` = NULL WHERE `hashtag5` IS NOT NULL AND `hashtag5`='' AND `id_tweet`>=@first_tweet_id;

	/* set ID's for existing hashtags */
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag1` SET `id_hashtag1` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_tweet`>=@first_tweet_id;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag2` SET `id_hashtag2` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_tweet`>=@first_tweet_id;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag3` SET `id_hashtag3` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_tweet`>=@first_tweet_id;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag4` SET `id_hashtag4` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_tweet`>=@first_tweet_id;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag5` SET `id_hashtag5` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_tweet`>=@first_tweet_id;

	/* add any new hashtags ignoring duplicates */
	UPDATE `process` SET id_hashtag_before = (SELECT id_hashtag FROM hashtag ORDER BY id_hashtag DESC LIMIT 1) WHERE `id_process`=@id_process;
	INSERT IGNORE INTO `hashtag` (`hashtag`) SELECT `hashtag1` FROM `tweet` WHERE `tweet`.`id_tweet`>=@first_tweet_id AND `hashtag1` IS NOT NULL;
	INSERT IGNORE INTO `hashtag` (`hashtag`) SELECT `hashtag2` FROM `tweet` WHERE `tweet`.`id_tweet`>=@first_tweet_id AND `hashtag1` IS NOT NULL;
	INSERT IGNORE INTO `hashtag` (`hashtag`) SELECT `hashtag3` FROM `tweet` WHERE `tweet`.`id_tweet`>=@first_tweet_id AND `hashtag1` IS NOT NULL;
	INSERT IGNORE INTO `hashtag` (`hashtag`) SELECT `hashtag4` FROM `tweet` WHERE `tweet`.`id_tweet`>=@first_tweet_id AND `hashtag1` IS NOT NULL;
	INSERT IGNORE INTO `hashtag` (`hashtag`) SELECT `hashtag5` FROM `tweet` WHERE `tweet`.`id_tweet`>=@first_tweet_id AND `hashtag1` IS NOT NULL;
	UPDATE `process` SET id_hashtag_after = (SELECT id_hashtag FROM hashtag ORDER BY id_hashtag DESC LIMIT 1) WHERE `id_process`=@id_process;

	/* set ID's for new hashtags */
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag1` SET `id_hashtag1` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_tweet`>=@first_tweet_id;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag2` SET `id_hashtag2` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_tweet`>=@first_tweet_id;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag3` SET `id_hashtag3` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_tweet`>=@first_tweet_id;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag4` SET `id_hashtag4` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_tweet`>=@first_tweet_id;
	UPDATE tweet JOIN `hashtag` ON `hashtag`.`hashtag`=`tweet`.`hashtag5` SET `id_hashtag5` = `hashtag`.`id_hashtag` WHERE `tweet`.`id_tweet`>=@first_tweet_id;

	/* since the new hashtags are in 5 columns, consolidate them into 1 temporary table */
	DROP TABLE IF EXISTS `tweet_tmp`;
	CREATE TABLE `tweet_tmp` (
	`id_tweet` INT(11),
	`id_hashtag` INT(11),
	`id_twitter` VARCHAR(30),
	`author_id` VARCHAR(30),
	`author_username` VARCHAR(255),
	`created_ts` TIMESTAMP,
	`currency` VARCHAR(4),
	`amount` INT(11),
	`is_bid` TINYINT(1),
	`lastchar` CHAR(1),
	KEY `id_hashtag` (`id_hashtag`)
	) ENGINE=INNODB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

	INSERT INTO `tweet_tmp` (`id_tweet`,`id_hashtag`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `lastchar` ) SELECT `id_tweet`,`id_hashtag1`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `lastchar`  FROM `tweet` WHERE `tweet`.`id_tweet`>=@first_tweet_id AND `id_hashtag1` IS NOT NULL;
	INSERT INTO `tweet_tmp` (`id_tweet`,`id_hashtag`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `lastchar` ) SELECT `id_tweet`,`id_hashtag2`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `lastchar`  FROM `tweet` WHERE `tweet`.`id_tweet`>=@first_tweet_id AND `id_hashtag2` IS NOT NULL;
	INSERT INTO `tweet_tmp` (`id_tweet`,`id_hashtag`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `lastchar` ) SELECT `id_tweet`,`id_hashtag3`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `lastchar`  FROM `tweet` WHERE `tweet`.`id_tweet`>=@first_tweet_id AND `id_hashtag3` IS NOT NULL;
	INSERT INTO `tweet_tmp` (`id_tweet`,`id_hashtag`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `lastchar` ) SELECT `id_tweet`,`id_hashtag4`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `lastchar`  FROM `tweet` WHERE `tweet`.`id_tweet`>=@first_tweet_id AND `id_hashtag4` IS NOT NULL;
	INSERT INTO `tweet_tmp` (`id_tweet`,`id_hashtag`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `lastchar` ) SELECT `id_tweet`,`id_hashtag5`,`id_twitter`,`author_id`,`author_username`,`created_ts`,`currency`,`amount`,`is_bid`, `lastchar`  FROM `tweet` WHERE `tweet`.`id_tweet`>=@first_tweet_id AND `id_hashtag5` IS NOT NULL;

	/* The first new tweet ( MIN(id_tweet) ) should be the 'author' that is referenced in the hashtag */
	UPDATE `hashtag` JOIN 
	(SELECT MIN(id_tweet) AS id_tweet_min,id_hashtag FROM tweet_tmp GROUP BY id_hashtag) AS tweet_new ON `hashtag`.`id_hashtag`=`tweet_new`.`id_hashtag`
	SET `hashtag`.`id_tweet`=`tweet_new`.`id_tweet_min` WHERE `hashtag`.`id_tweet` IS NULL;

	/* Update the rest of the data in hashtag to point to it */
	UPDATE `hashtag` JOIN `tweet` ON `hashtag`.`id_tweet`=`tweet`.`id_tweet`
	SET `hashtag`.`id_twitter`=`tweet`.`id_twitter`,`hashtag`.`author_id`=`tweet`.`author_id`,`hashtag`.`author_username`=`tweet`.`author_username`,`hashtag`.`created_ts`=`tweet`.`created_ts`,`hashtag`.`title`=`tweet`.`text`
	WHERE `hashtag`.`id_tweet`>=@first_tweet_id ;

	/* all new tweets ending with 't' means if it's the same author we need to update and point to this new tweet */
	UPDATE hashtag JOIN
	(SELECT MAX(id_tweet) AS id_tweet,id_hashtag,author_id FROM tweet_tmp WHERE lastchar='t' GROUP BY id_hashtag,author_id) AS tweets_update
		ON hashtag.id_hashtag=tweets_update.id_hashtag AND hashtag.author_id=tweets_update.author_id
	JOIN tweet ON tweet.id_tweet=tweets_update.id_tweet
	SET hashtag.id_tweet=tweet.id_tweet,hashtag.id_twitter=tweet.id_twitter;

	/* update changes to author */
	
	/* NEED TO ADD THIS ONCE THE ID_TWEET_REFERENCED IS ADDED */

	/* all new tweets ending with 'd' means if it's the same author we need to update the description in the title field */
	UPDATE hashtag JOIN
	(SELECT MAX(id_tweet) AS id_tweet,id_hashtag,author_id FROM tweet_tmp WHERE lastchar='d' GROUP BY id_hashtag,author_id) AS tweets_update
		ON hashtag.id_hashtag=tweets_update.id_hashtag AND hashtag.author_id=tweets_update.author_id
	JOIN tweet ON tweet.id_tweet=tweets_update.id_tweet
	SET hashtag.title=tweet.text;
	
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

	/* drop the temporary table */

	/* close out this */
	UPDATE `process` SET finished_ts=NOW() WHERE `id_process`=@id_process ;	
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tweet`
--

CREATE TABLE `tweet` (
  `id_tweet` int(11) UNSIGNED NOT NULL,
  `id_twitter` varchar(30) DEFAULT NULL,
  `id_twitter_referenced` varchar(30) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `created_at` varchar(50) DEFAULT NULL,
  `author_id` varchar(30) DEFAULT NULL,
  `conversation_id` varchar(30) DEFAULT NULL,
  `retweet_count` int(10) UNSIGNED DEFAULT NULL,
  `reply_count` int(10) UNSIGNED DEFAULT NULL,
  `like_count` int(10) UNSIGNED DEFAULT NULL,
  `quote_count` int(10) UNSIGNED DEFAULT NULL,
  `lang` varchar(3) DEFAULT NULL,
  `reply_settings` varchar(15) DEFAULT NULL,
  `author_name` varchar(255) DEFAULT NULL,
  `author_username` varchar(255) DEFAULT NULL,
  `author_created_at` varchar(50) DEFAULT NULL,
  `author_verified` tinyint(1) DEFAULT NULL,
  `author_followers_count` int(10) UNSIGNED DEFAULT NULL,
  `author_following_count` int(10) UNSIGNED DEFAULT NULL,
  `author_tweet_count` int(10) UNSIGNED DEFAULT NULL,
  `author_listed_count` int(10) UNSIGNED DEFAULT NULL,
  `currency` varchar(3) DEFAULT NULL,
  `amount` varchar(20) DEFAULT NULL,
  `hashtag1` varchar(60) DEFAULT NULL,
  `hashtag2` varchar(60) DEFAULT NULL,
  `hashtag3` varchar(60) DEFAULT NULL,
  `hashtag4` varchar(60) DEFAULT NULL,
  `hashtag5` varchar(60) DEFAULT NULL,
  `id_hashtag1` int(11) UNSIGNED DEFAULT NULL,
  `id_hashtag2` int(11) UNSIGNED DEFAULT NULL,
  `id_hashtag3` int(11) UNSIGNED DEFAULT NULL,
  `id_hashtag4` int(11) UNSIGNED DEFAULT NULL,
  `id_hashtag5` int(11) UNSIGNED DEFAULT NULL,
  `id_tweet_replaced` int(11) UNSIGNED DEFAULT NULL,
  `is_bid` tinyint(1) DEFAULT 0,
  `lastchar` char(1) DEFAULT NULL,
  `tweet_time` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tweet`
--
ALTER TABLE `tweet`
  ADD PRIMARY KEY (`id_tweet`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tweet`
--
ALTER TABLE `tweet`
  MODIFY `id_tweet` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
