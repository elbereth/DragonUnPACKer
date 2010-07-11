--
-- The contents of this file are subject to the Mozilla Public License
-- Version 1.1 (the "License"); you may not use this file except in compliance
-- with the License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
--
-- Software distributed under the License is distributed on an "AS IS" basis,
-- WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
-- specific language governing rights and limitations under the License.
--
-- The Original Code is dus.sql, released December 17, 2005.
--
-- The Initial Developer of the Original Code is Alexandre Devilliers
-- (elbereth@users.sourceforge.net, http://www.elberethzone.net).
--

-- phpMyAdmin SQL Dump
-- version 3.3.3
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 11, 2010 at 03:18 PM
-- Server version: 5.1.47
-- PHP Version: 5.3.2

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `d108923_DragonUnPACKer`
--

-- --------------------------------------------------------

--
-- Table structure for table `dus_convert`
--

CREATE TABLE `dus_convert` (
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
  PRIMARY KEY (`name`,`version`),
  KEY `duci` (`duci`),
  KEY `versiontype` (`versiontype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_core`
--

CREATE TABLE `dus_core` (
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

CREATE TABLE `dus_core_update` (
  `buildfrom` int(11) NOT NULL,
  `buildto` int(11) NOT NULL,
  `URL` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL,
  `realsize` int(11) NOT NULL,
  `hash` varchar(40) NOT NULL,
  PRIMARY KEY (`buildfrom`,`buildto`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_driver`
--

CREATE TABLE `dus_driver` (
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

CREATE TABLE `dus_duppi` (
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

CREATE TABLE `dus_hyperripper` (
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

CREATE TABLE `dus_servers` (
  `serverID` tinyint(4) NOT NULL,
  `serverPriority` int(11) NOT NULL DEFAULT '0',
  `serverCountry` varchar(2) CHARACTER SET ascii NOT NULL DEFAULT 'fr',
  `serverURL` text NOT NULL,
  `serverName` varchar(128) NOT NULL,
  `serverEnabled` enum('true','false') CHARACTER SET ascii NOT NULL DEFAULT 'true',
  `serverUsePaths` enum('true','false') NOT NULL DEFAULT 'true',
  PRIMARY KEY (`serverID`),
  KEY `serverPriority` (`serverPriority`,`serverEnabled`),
  KEY `serverUsePaths` (`serverUsePaths`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_translation`
--

CREATE TABLE `dus_translation` (
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

CREATE TABLE `dus_versions` (
  `dupfrom` int(11) NOT NULL,
  `dupto` int(11) NOT NULL,
  `duci` int(11) NOT NULL DEFAULT '0',
  `dudi` int(11) NOT NULL DEFAULT '0',
  `duhi` int(11) NOT NULL DEFAULT '0',
  `translation` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`dupfrom`,`dupto`),
  KEY `convert` (`duci`,`dudi`,`duhi`,`translation`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
