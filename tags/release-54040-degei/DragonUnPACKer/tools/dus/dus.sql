-- $Id: dus.sql,v 1.3 2008-11-15 18:42:05 elbereth Exp $
-- $Source: /home/elbzone/backup/cvs/DragonUnPACKer/tools/dus/dus.sql,v $
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
-- version 2.11.7
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Nov 15, 2008 at 06:39 PM
-- Server version: 5.0.51
-- PHP Version: 5.2.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `d108923_DragonUnPACKer`
--

-- --------------------------------------------------------

--
-- Table structure for table `dus_convert`
--

CREATE TABLE `dus_convert` (
  `name` varchar(12) NOT NULL,
  `version` int(11) NOT NULL default '0',
  `versiontype` enum('stable','unstable') NOT NULL default 'stable',
  `description` text NOT NULL,
  `duci` tinyint(4) NOT NULL default '0',
  `versiondisp` varchar(32) NOT NULL,
  `URL` text NOT NULL,
  `file` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL default '0',
  `comment` text NOT NULL,
  `commentFR` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`name`,`version`),
  KEY `duci` (`duci`),
  KEY `versiontype` (`versiontype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_core`
--

CREATE TABLE `dus_core` (
  `build` int(11) NOT NULL default '0',
  `date` date NOT NULL default '0000-00-00',
  `type` enum('wip','stable') character set utf8 NOT NULL default 'wip',
  `versiondisp` varchar(64) character set utf8 NOT NULL,
  `URL` text character set utf8 NOT NULL,
  `UpdateURL` text character set utf8,
  `available` enum('no','yes') character set utf8 NOT NULL default 'no',
  PRIMARY KEY  (`build`)
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
  PRIMARY KEY  (`buildfrom`,`buildto`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_driver`
--

CREATE TABLE `dus_driver` (
  `name` varchar(12) NOT NULL,
  `version` int(11) NOT NULL default '0',
  `versiontype` enum('stable','unstable') NOT NULL default 'stable',
  `description` text NOT NULL,
  `dudi` tinyint(4) NOT NULL default '0',
  `versiondisp` varchar(32) NOT NULL,
  `URL` text NOT NULL,
  `file` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL default '0',
  `comment` text NOT NULL,
  `commentFR` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`name`,`version`),
  KEY `dudi` (`dudi`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_duppi`
--

CREATE TABLE `dus_duppi` (
  `version` int(11) NOT NULL,
  `versiondisp` varchar(32) NOT NULL,
  `URL` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL,
  PRIMARY KEY  (`version`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_hyperripper`
--

CREATE TABLE `dus_hyperripper` (
  `name` varchar(12) NOT NULL,
  `version` int(11) NOT NULL default '0',
  `versiontype` enum('stable','unstable') NOT NULL default 'stable',
  `description` text NOT NULL,
  `duhi` tinyint(4) NOT NULL default '0',
  `versiondisp` varchar(32) NOT NULL,
  `URL` text NOT NULL,
  `file` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL default '0',
  `comment` text NOT NULL,
  `commentFR` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`name`,`version`),
  KEY `duhi` (`duhi`),
  KEY `versiontype` (`versiontype`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_servers`
--

CREATE TABLE `dus_servers` (
  `serverID` tinyint(4) NOT NULL,
  `serverPriority` int(11) NOT NULL default '0',
  `serverCountry` varchar(2) character set ascii NOT NULL default 'fr',
  `serverURL` text NOT NULL,
  `serverName` varchar(128) NOT NULL,
  `serverEnabled` enum('true','false') character set ascii NOT NULL default 'true',
  `serverUsePaths` enum('true','false') NOT NULL default 'true',
  PRIMARY KEY  (`serverID`),
  KEY `serverPriority` (`serverPriority`,`serverEnabled`),
  KEY `serverUsePaths` (`serverUsePaths`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_translation`
--

CREATE TABLE `dus_translation` (
  `name` varchar(32) NOT NULL,
  `version` tinyint(4) NOT NULL default '0',
  `release` tinyint(4) NOT NULL default '0',
  `description` varchar(128) NOT NULL,
  `author` text NOT NULL,
  `URL` text NOT NULL,
  `file` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL default '0',
  `date` date NOT NULL default '0000-00-00',
  PRIMARY KEY  (`name`,`version`,`release`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `dus_versions`
--

CREATE TABLE `dus_versions` (
  `dupfrom` int(11) NOT NULL,
  `dupto` int(11) NOT NULL,
  `duci` int(11) NOT NULL default '0',
  `dudi` int(11) NOT NULL default '0',
  `duhi` int(11) NOT NULL default '0',
  `translation` int(11) NOT NULL default '0',
  PRIMARY KEY  (`dupfrom`,`dupto`),
  KEY `convert` (`duci`,`dudi`,`duhi`,`translation`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
