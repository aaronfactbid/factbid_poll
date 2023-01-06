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
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `process_tweets` (IN `first_tweet_id` INT(11))   BEGIN
	SELECT * FROM tweet WHERE id_tweet >= first_tweet_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tweet`
--

CREATE TABLE `tweet` (
  `id_tweet` int(11) UNSIGNED NOT NULL,
  `id_twitter` varchar(30) DEFAULT NULL,
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
