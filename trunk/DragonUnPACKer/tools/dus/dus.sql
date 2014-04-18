--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--
-- The Original Code is dus.sql, released December 17, 2005.
--
-- The Initial Developer of the Original Code is Alexandre Devilliers
-- (elbereth@users.sourceforge.net, http://www.elberethzone.net).
--

-- phpMyAdmin SQL Dump
-- version 4.1.13
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 18, 2014 at 10:25 PM
-- Server version: 5.5.35-2-log
-- PHP Version: 5.5.10-1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

-- --------------------------------------------------------

--
-- Table structure for table `dus_convert`
--

CREATE TABLE IF NOT EXISTS `dus_convert` (
  `name` varchar(12) NOT NULL,
  `version` int(11) NOT NULL DEFAULT '0',
  `versiontype` enum('stable','unstable') NOT NULL DEFAULT 'stable',
  `description` text NOT NULL,
  `duci` tinyint(4) NOT NULL DEFAULT '0',
  `versiondisp` varchar(32) NOT NULL,
  `URL` text NOT NULL,
  `file` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL DEFAULT '0',
  `comment` text NOT NULL,
  `commentFR` text NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `realsize` bigint(20) NOT NULL,
  `hash` varchar(40) NOT NULL,
  PRIMARY KEY (`name`,`version`),
  KEY `duci` (`duci`),
  KEY `versiontype` (`versiontype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_core`
--

CREATE TABLE IF NOT EXISTS `dus_core` (
  `build` int(11) NOT NULL DEFAULT '0',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `type` enum('wip','stable') CHARACTER SET utf8 NOT NULL DEFAULT 'wip',
  `versiondisp` varchar(64) CHARACTER SET utf8 NOT NULL,
  `URL` text CHARACTER SET utf8 NOT NULL,
  `UpdateURL` text CHARACTER SET utf8,
  `available` enum('no','yes') CHARACTER SET utf8 NOT NULL DEFAULT 'no',
  PRIMARY KEY (`build`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `dus_core_update`
--

CREATE TABLE IF NOT EXISTS `dus_core_update` (
  `buildfrom` int(11) NOT NULL,
  `buildto` int(11) NOT NULL,
  `URL` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL,
  `realsize` int(11) NOT NULL,
  `hash` varchar(40) NOT NULL,
  `URLSF` text NOT NULL,
  PRIMARY KEY (`buildfrom`,`buildto`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_driver`
--

CREATE TABLE IF NOT EXISTS `dus_driver` (
  `name` varchar(12) NOT NULL,
  `version` int(11) NOT NULL DEFAULT '0',
  `versiontype` enum('stable','unstable') NOT NULL DEFAULT 'stable',
  `description` text NOT NULL,
  `dudi` tinyint(4) NOT NULL DEFAULT '0',
  `versiondisp` varchar(32) NOT NULL,
  `URL` text NOT NULL,
  `file` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL DEFAULT '0',
  `comment` text NOT NULL,
  `commentFR` text NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `realsize` bigint(20) NOT NULL DEFAULT '0',
  `hash` varchar(40) NOT NULL,
  PRIMARY KEY (`name`,`version`),
  KEY `dudi` (`dudi`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_duppi`
--

CREATE TABLE IF NOT EXISTS `dus_duppi` (
  `versionfrom` int(11) NOT NULL DEFAULT '0',
  `version` int(11) NOT NULL,
  `versiondisp` varchar(32) NOT NULL,
  `URL` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL,
  `realsize` int(11) NOT NULL,
  `hash` varchar(40) NOT NULL,
  PRIMARY KEY (`versionfrom`,`version`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_hyperripper`
--

CREATE TABLE IF NOT EXISTS `dus_hyperripper` (
  `name` varchar(12) NOT NULL,
  `version` int(11) NOT NULL DEFAULT '0',
  `versiontype` enum('stable','unstable') NOT NULL DEFAULT 'stable',
  `description` text NOT NULL,
  `duhi` tinyint(4) NOT NULL DEFAULT '0',
  `versiondisp` varchar(32) NOT NULL,
  `URL` text NOT NULL,
  `file` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL DEFAULT '0',
  `comment` text NOT NULL,
  `commentFR` text NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`name`,`version`),
  KEY `duhi` (`duhi`),
  KEY `versiontype` (`versiontype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_servers`
--

CREATE TABLE IF NOT EXISTS `dus_servers` (
  `serverID` tinyint(4) NOT NULL,
  `serverPriority` int(11) NOT NULL DEFAULT '0',
  `serverCountry` varchar(2) CHARACTER SET ascii NOT NULL DEFAULT 'fr',
  `serverURL` text NOT NULL,
  `serverName` varchar(128) NOT NULL,
  `serverEnabled` enum('true','false') CHARACTER SET ascii NOT NULL DEFAULT 'true',
  `serverUsePaths` enum('true','false','sourceforge') NOT NULL DEFAULT 'true',
  PRIMARY KEY (`serverID`),
  KEY `serverPriority` (`serverPriority`,`serverEnabled`),
  KEY `serverUsePaths` (`serverUsePaths`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_translation`
--

CREATE TABLE IF NOT EXISTS `dus_translation` (
  `name` varchar(32) NOT NULL,
  `version` tinyint(4) NOT NULL DEFAULT '0',
  `release` tinyint(4) NOT NULL DEFAULT '0',
  `description` varchar(128) NOT NULL,
  `author` text NOT NULL,
  `URL` text NOT NULL,
  `file` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL DEFAULT '0',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `realsize` int(11) NOT NULL,
  `hash` varchar(40) NOT NULL,
  PRIMARY KEY (`name`,`version`,`release`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_versions`
--

CREATE TABLE IF NOT EXISTS `dus_versions` (
  `dupfrom` int(11) NOT NULL,
  `dupto` int(11) NOT NULL,
  `ducifrom` int(11) NOT NULL DEFAULT '0',
  `ducito` int(11) NOT NULL DEFAULT '0',
  `dudifrom` int(11) NOT NULL DEFAULT '0',
  `dudito` int(11) NOT NULL DEFAULT '0',
  `duhi` int(11) NOT NULL DEFAULT '0',
  `translation` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`dupfrom`,`dupto`),
  KEY `convert` (`ducifrom`,`dudifrom`,`duhi`,`translation`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
