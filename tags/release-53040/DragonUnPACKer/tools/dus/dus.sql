-- phpMyAdmin SQL Dump
-- version 2.7.0-pl1
-- http://www.phpmyadmin.net
-- 
-- Host: pr-db2
-- Generation Time: Dec 16, 2005 at 03:58 PM
-- Server version: 4.1.12
-- PHP Version: 4.3.9
-- 
-- Database: `d108923_DragonUnPACKer`
-- 

-- --------------------------------------------------------

-- 
-- Table structure for table `dus_convert`
-- 

CREATE TABLE `dus_convert` (
  `name` varchar(12) NOT NULL default '',
  `version` int(11) NOT NULL default '0',
  `description` text NOT NULL,
  `duci` tinyint(4) NOT NULL default '0',
  `versiondisp` varchar(32) NOT NULL default '',
  `URL` text NOT NULL,
  `file` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL default '0',
  `comment` text NOT NULL,
  `commentFR` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`name`,`version`),
  KEY `duci` (`duci`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `dus_core`
-- 

CREATE TABLE `dus_core` (
  `build` int(11) NOT NULL default '0',
  `date` date NOT NULL default '0000-00-00',
  `type` enum('wip','stable') NOT NULL default 'wip',
  `versiondisp` varchar(64) NOT NULL default '',
  `URL` text NOT NULL,
  `available` enum('no','yes') NOT NULL default 'no',
  PRIMARY KEY  (`build`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `dus_driver`
-- 

CREATE TABLE `dus_driver` (
  `name` varchar(12) NOT NULL default '',
  `version` int(11) NOT NULL default '0',
  `description` text NOT NULL,
  `dudi` tinyint(4) NOT NULL default '0',
  `versiondisp` varchar(32) NOT NULL default '',
  `URL` text NOT NULL,
  `file` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL default '0',
  `comment` text NOT NULL,
  `commentFR` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`name`,`version`),
  KEY `dudi` (`dudi`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `dus_hyperripper`
-- 

CREATE TABLE `dus_hyperripper` (
  `name` varchar(12) NOT NULL default '',
  `version` int(11) NOT NULL default '0',
  `description` text NOT NULL,
  `duhi` tinyint(4) NOT NULL default '0',
  `versiondisp` varchar(32) NOT NULL default '',
  `URL` text NOT NULL,
  `file` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL default '0',
  `comment` text NOT NULL,
  `commentFR` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`name`,`version`),
  KEY `duhi` (`duhi`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `dus_translation`
-- 

CREATE TABLE `dus_translation` (
  `name` varchar(32) NOT NULL default '',
  `version` tinyint(4) NOT NULL default '0',
  `release` tinyint(4) NOT NULL default '0',
  `description` varchar(128) NOT NULL default '',
  `author` text NOT NULL,
  `URL` text NOT NULL,
  `file` text NOT NULL,
  `fileDL` text NOT NULL,
  `size` int(11) NOT NULL default '0',
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  PRIMARY KEY  (`name`,`version`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

-- 
-- Table structure for table `dus_versions`
-- 

CREATE TABLE `dus_versions` (
  `dup` int(11) NOT NULL default '0',
  `duci` int(11) NOT NULL default '0',
  `dudi` int(11) NOT NULL default '0',
  `duhi` int(11) NOT NULL default '0',
  `translation` int(11) NOT NULL default '0',
  PRIMARY KEY  (`dup`),
  KEY `convert` (`duci`,`dudi`,`duhi`,`translation`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
