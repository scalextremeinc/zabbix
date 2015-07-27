-- there should be no drops here so this script can be run multiple times

CREATE DATABASE zabbix;
USE zabbix;

-- MySQL dump 10.13  Distrib 5.1.67, for redhat-linux-gnu (x86_64)
--
-- Host: 127.0.0.1    Database: zabbix
-- ------------------------------------------------------
-- Server version	5.1.67

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `acknowledges`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `acknowledges` (
  `acknowledgeid` bigint(20) unsigned NOT NULL,
  `userid` bigint(20) unsigned NOT NULL,
  `eventid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `message` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`acknowledgeid`),
  KEY `acknowledges_1` (`userid`),
  KEY `acknowledges_2` (`eventid`),
  KEY `acknowledges_3` (`clock`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `actions`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `actions` (
  `actionid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `eventsource` int(11) NOT NULL DEFAULT '0',
  `evaltype` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  `esc_period` int(11) NOT NULL DEFAULT '0',
  `def_shortdata` varchar(255) NOT NULL DEFAULT '',
  `def_longdata` text NOT NULL,
  `recovery_msg` int(11) NOT NULL DEFAULT '0',
  `r_shortdata` varchar(255) NOT NULL DEFAULT '',
  `r_longdata` text NOT NULL,
  PRIMARY KEY (`actionid`),
  KEY `actions_1` (`eventsource`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `alerts`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alerts` (
  `alertid` bigint(20) unsigned NOT NULL,
  `actionid` bigint(20) unsigned NOT NULL,
  `eventid` bigint(20) unsigned NOT NULL,
  `userid` bigint(20) unsigned DEFAULT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `mediatypeid` bigint(20) unsigned DEFAULT NULL,
  `sendto` varchar(100) NOT NULL DEFAULT '',
  `subject` varchar(255) NOT NULL DEFAULT '',
  `message` text NOT NULL,
  `status` int(11) NOT NULL DEFAULT '0',
  `retries` int(11) NOT NULL DEFAULT '0',
  `error` varchar(128) NOT NULL DEFAULT '',
  `nextcheck` int(11) NOT NULL DEFAULT '0',
  `esc_step` int(11) NOT NULL DEFAULT '0',
  `alerttype` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`alertid`),
  KEY `alerts_1` (`actionid`),
  KEY `alerts_2` (`clock`),
  KEY `alerts_3` (`eventid`),
  KEY `alerts_4` (`status`,`retries`),
  KEY `alerts_5` (`mediatypeid`),
  KEY `alerts_6` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `applications`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `applications` (
  `applicationid` bigint(20) unsigned NOT NULL,
  `hostid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `templateid` bigint(20) unsigned DEFAULT NULL,
  `os` varchar(255) DEFAULT '',
  PRIMARY KEY (`applicationid`),
  UNIQUE KEY `applications_2` (`hostid`,`name`),
  KEY `applications_1` (`templateid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auditlog`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditlog` (
  `auditid` bigint(20) unsigned NOT NULL,
  `userid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `action` int(11) NOT NULL DEFAULT '0',
  `resourcetype` int(11) NOT NULL DEFAULT '0',
  `details` varchar(128) NOT NULL DEFAULT '0',
  `ip` varchar(39) NOT NULL DEFAULT '',
  `resourceid` bigint(20) unsigned NOT NULL DEFAULT '0',
  `resourcename` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`auditid`),
  KEY `auditlog_1` (`userid`,`clock`),
  KEY `auditlog_2` (`clock`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auditlog_details`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditlog_details` (
  `auditdetailid` bigint(20) unsigned NOT NULL,
  `auditid` bigint(20) unsigned NOT NULL,
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `field_name` varchar(64) NOT NULL DEFAULT '',
  `oldvalue` text NOT NULL,
  `newvalue` text NOT NULL,
  PRIMARY KEY (`auditdetailid`),
  KEY `auditlog_details_1` (`auditid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `autocreate`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `autocreate` (
  `app` varchar(255) NOT NULL,
  `enabled` int(11) NOT NULL DEFAULT '0',
  `prefix` varchar(255) NOT NULL,
  `delta` int(11) NOT NULL DEFAULT '0',
  KEY `app` (`app`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `autoreg_host`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `autoreg_host` (
  `autoreg_hostid` bigint(20) unsigned NOT NULL,
  `proxy_hostid` bigint(20) unsigned DEFAULT NULL,
  `host` varchar(64) NOT NULL DEFAULT '',
  `listen_ip` varchar(39) NOT NULL DEFAULT '',
  `listen_port` int(11) NOT NULL DEFAULT '0',
  `listen_dns` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`autoreg_hostid`),
  KEY `autoreg_host_1` (`proxy_hostid`,`host`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `avail`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `avail` (
  `itemid` bigint(20) unsigned NOT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  `enabled` int(11) NOT NULL DEFAULT '0',
  `parameters` text,
  PRIMARY KEY (`itemid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `collectors`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `collectors` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `path` varchar(1024) NOT NULL,
  `parameters` text,
  `mtime` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `conditions`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conditions` (
  `conditionid` bigint(20) unsigned NOT NULL,
  `actionid` bigint(20) unsigned NOT NULL,
  `conditiontype` int(11) NOT NULL DEFAULT '0',
  `operator` int(11) NOT NULL DEFAULT '0',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`conditionid`),
  KEY `conditions_1` (`actionid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `config`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `config` (
  `configid` bigint(20) unsigned NOT NULL,
  `alert_history` int(11) NOT NULL DEFAULT '0',
  `event_history` int(11) NOT NULL DEFAULT '0',
  `refresh_unsupported` int(11) NOT NULL DEFAULT '0',
  `work_period` varchar(100) NOT NULL DEFAULT '1-5,00:00-24:00',
  `alert_usrgrpid` bigint(20) unsigned DEFAULT NULL,
  `event_ack_enable` int(11) NOT NULL DEFAULT '1',
  `event_expire` int(11) NOT NULL DEFAULT '7',
  `event_show_max` int(11) NOT NULL DEFAULT '100',
  `default_theme` varchar(128) NOT NULL DEFAULT 'originalblue',
  `authentication_type` int(11) NOT NULL DEFAULT '0',
  `ldap_host` varchar(255) NOT NULL DEFAULT '',
  `ldap_port` int(11) NOT NULL DEFAULT '389',
  `ldap_base_dn` varchar(255) NOT NULL DEFAULT '',
  `ldap_bind_dn` varchar(255) NOT NULL DEFAULT '',
  `ldap_bind_password` varchar(128) NOT NULL DEFAULT '',
  `ldap_search_attribute` varchar(128) NOT NULL DEFAULT '',
  `dropdown_first_entry` int(11) NOT NULL DEFAULT '1',
  `dropdown_first_remember` int(11) NOT NULL DEFAULT '1',
  `discovery_groupid` bigint(20) unsigned NOT NULL,
  `max_in_table` int(11) NOT NULL DEFAULT '50',
  `search_limit` int(11) NOT NULL DEFAULT '1000',
  `severity_color_0` varchar(6) NOT NULL DEFAULT 'DBDBDB',
  `severity_color_1` varchar(6) NOT NULL DEFAULT 'D6F6FF',
  `severity_color_2` varchar(6) NOT NULL DEFAULT 'FFF6A5',
  `severity_color_3` varchar(6) NOT NULL DEFAULT 'FFB689',
  `severity_color_4` varchar(6) NOT NULL DEFAULT 'FF9999',
  `severity_color_5` varchar(6) NOT NULL DEFAULT 'FF3838',
  `severity_name_0` varchar(32) NOT NULL DEFAULT 'Not classified',
  `severity_name_1` varchar(32) NOT NULL DEFAULT 'Information',
  `severity_name_2` varchar(32) NOT NULL DEFAULT 'Warning',
  `severity_name_3` varchar(32) NOT NULL DEFAULT 'Average',
  `severity_name_4` varchar(32) NOT NULL DEFAULT 'High',
  `severity_name_5` varchar(32) NOT NULL DEFAULT 'Disaster',
  `ok_period` int(11) NOT NULL DEFAULT '1800',
  `blink_period` int(11) NOT NULL DEFAULT '1800',
  `problem_unack_color` varchar(6) NOT NULL DEFAULT 'DC0000',
  `problem_ack_color` varchar(6) NOT NULL DEFAULT 'DC0000',
  `ok_unack_color` varchar(6) NOT NULL DEFAULT '00AA00',
  `ok_ack_color` varchar(6) NOT NULL DEFAULT '00AA00',
  `problem_unack_style` int(11) NOT NULL DEFAULT '1',
  `problem_ack_style` int(11) NOT NULL DEFAULT '1',
  `ok_unack_style` int(11) NOT NULL DEFAULT '1',
  `ok_ack_style` int(11) NOT NULL DEFAULT '1',
  `snmptrap_logging` int(11) NOT NULL DEFAULT '1',
  `server_check_interval` int(11) NOT NULL DEFAULT '60',
  PRIMARY KEY (`configid`),
  KEY `c_config_1` (`alert_usrgrpid`),
  KEY `c_config_2` (`discovery_groupid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dchecks`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dchecks` (
  `dcheckid` bigint(20) unsigned NOT NULL,
  `druleid` bigint(20) unsigned NOT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  `key_` varchar(255) NOT NULL DEFAULT '',
  `snmp_community` varchar(255) NOT NULL DEFAULT '',
  `ports` varchar(255) NOT NULL DEFAULT '0',
  `snmpv3_securityname` varchar(64) NOT NULL DEFAULT '',
  `snmpv3_securitylevel` int(11) NOT NULL DEFAULT '0',
  `snmpv3_authpassphrase` varchar(64) NOT NULL DEFAULT '',
  `snmpv3_privpassphrase` varchar(64) NOT NULL DEFAULT '',
  `uniq` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`dcheckid`),
  KEY `dchecks_1` (`druleid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dhosts`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dhosts` (
  `dhostid` bigint(20) unsigned NOT NULL,
  `druleid` bigint(20) unsigned NOT NULL,
  `status` int(11) NOT NULL DEFAULT '0',
  `lastup` int(11) NOT NULL DEFAULT '0',
  `lastdown` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`dhostid`),
  KEY `dhosts_1` (`druleid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `drules`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `drules` (
  `druleid` bigint(20) unsigned NOT NULL,
  `proxy_hostid` bigint(20) unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `iprange` varchar(255) NOT NULL DEFAULT '',
  `delay` int(11) NOT NULL DEFAULT '3600',
  `nextcheck` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`druleid`),
  KEY `c_drules_1` (`proxy_hostid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dservices`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dservices` (
  `dserviceid` bigint(20) unsigned NOT NULL,
  `dhostid` bigint(20) unsigned NOT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  `key_` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  `port` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  `lastup` int(11) NOT NULL DEFAULT '0',
  `lastdown` int(11) NOT NULL DEFAULT '0',
  `dcheckid` bigint(20) unsigned NOT NULL,
  `ip` varchar(39) NOT NULL DEFAULT '',
  `dns` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`dserviceid`),
  UNIQUE KEY `dservices_1` (`dcheckid`,`type`,`key_`,`ip`,`port`),
  KEY `dservices_2` (`dhostid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `escalations`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `escalations` (
  `escalationid` bigint(20) unsigned NOT NULL,
  `actionid` bigint(20) unsigned NOT NULL,
  `triggerid` bigint(20) unsigned DEFAULT NULL,
  `eventid` bigint(20) unsigned DEFAULT NULL,
  `r_eventid` bigint(20) unsigned DEFAULT NULL,
  `nextcheck` int(11) NOT NULL DEFAULT '0',
  `esc_step` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`escalationid`),
  KEY `escalations_1` (`actionid`,`triggerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `events`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `events` (
  `eventid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `source` int(11) NOT NULL DEFAULT '0',
  `object` int(11) NOT NULL DEFAULT '0',
  `objectid` bigint(20) unsigned NOT NULL DEFAULT '0',
  `clock` int(11) NOT NULL DEFAULT '0',
  `value` int(11) NOT NULL DEFAULT '0',
  `acknowledged` int(11) NOT NULL DEFAULT '0',
  `ns` int(11) NOT NULL DEFAULT '0',
  `value_changed` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`eventid`),
  KEY `events_1` (`object`,`objectid`,`eventid`),
  KEY `events_2` (`clock`)
) ENGINE=MyISAM AUTO_INCREMENT=850 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `expressions`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `expressions` (
  `expressionid` bigint(20) unsigned NOT NULL,
  `regexpid` bigint(20) unsigned NOT NULL,
  `expression` varchar(255) NOT NULL DEFAULT '',
  `expression_type` int(11) NOT NULL DEFAULT '0',
  `exp_delimiter` varchar(1) NOT NULL DEFAULT '',
  `case_sensitive` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`expressionid`),
  KEY `expressions_1` (`regexpid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `functions`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `functions` (
  `functionid` bigint(20) unsigned NOT NULL,
  `itemid` bigint(20) unsigned NOT NULL,
  `triggerid` bigint(20) unsigned NOT NULL,
  `function` varchar(12) NOT NULL DEFAULT '',
  `parameter` varchar(255) NOT NULL DEFAULT '0',
  PRIMARY KEY (`functionid`),
  KEY `functions_1` (`triggerid`),
  KEY `functions_2` (`itemid`,`function`,`parameter`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `globalmacro`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `globalmacro` (
  `globalmacroid` bigint(20) unsigned NOT NULL,
  `macro` varchar(64) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`globalmacroid`),
  KEY `globalmacro_1` (`macro`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `globalvars`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `globalvars` (
  `globalvarid` bigint(20) unsigned NOT NULL,
  `snmp_lastsize` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`globalvarid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `graph_discovery`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `graph_discovery` (
  `graphdiscoveryid` bigint(20) unsigned NOT NULL,
  `graphid` bigint(20) unsigned NOT NULL,
  `parent_graphid` bigint(20) unsigned NOT NULL,
  `name` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`graphdiscoveryid`),
  UNIQUE KEY `graph_discovery_1` (`graphid`,`parent_graphid`),
  KEY `c_graph_discovery_2` (`parent_graphid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `graph_theme`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `graph_theme` (
  `graphthemeid` bigint(20) unsigned NOT NULL,
  `description` varchar(64) NOT NULL DEFAULT '',
  `theme` varchar(64) NOT NULL DEFAULT '',
  `backgroundcolor` varchar(6) NOT NULL DEFAULT 'F0F0F0',
  `graphcolor` varchar(6) NOT NULL DEFAULT 'FFFFFF',
  `graphbordercolor` varchar(6) NOT NULL DEFAULT '222222',
  `gridcolor` varchar(6) NOT NULL DEFAULT 'CCCCCC',
  `maingridcolor` varchar(6) NOT NULL DEFAULT 'AAAAAA',
  `gridbordercolor` varchar(6) NOT NULL DEFAULT '000000',
  `textcolor` varchar(6) NOT NULL DEFAULT '202020',
  `highlightcolor` varchar(6) NOT NULL DEFAULT 'AA4444',
  `leftpercentilecolor` varchar(6) NOT NULL DEFAULT '11CC11',
  `rightpercentilecolor` varchar(6) NOT NULL DEFAULT 'CC1111',
  `nonworktimecolor` varchar(6) NOT NULL DEFAULT 'CCCCCC',
  `gridview` int(11) NOT NULL DEFAULT '1',
  `legendview` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`graphthemeid`),
  KEY `graph_theme_1` (`description`),
  KEY `graph_theme_2` (`theme`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `graphs`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `graphs` (
  `graphid` bigint(20) unsigned NOT NULL,
  `name` varchar(128) NOT NULL DEFAULT '',
  `width` int(11) NOT NULL DEFAULT '0',
  `height` int(11) NOT NULL DEFAULT '0',
  `yaxismin` double(16,4) NOT NULL DEFAULT '0.0000',
  `yaxismax` double(16,4) NOT NULL DEFAULT '0.0000',
  `templateid` bigint(20) unsigned DEFAULT NULL,
  `show_work_period` int(11) NOT NULL DEFAULT '1',
  `show_triggers` int(11) NOT NULL DEFAULT '1',
  `graphtype` int(11) NOT NULL DEFAULT '0',
  `show_legend` int(11) NOT NULL DEFAULT '1',
  `show_3d` int(11) NOT NULL DEFAULT '0',
  `percent_left` double(16,4) NOT NULL DEFAULT '0.0000',
  `percent_right` double(16,4) NOT NULL DEFAULT '0.0000',
  `ymin_type` int(11) NOT NULL DEFAULT '0',
  `ymax_type` int(11) NOT NULL DEFAULT '0',
  `ymin_itemid` bigint(20) unsigned DEFAULT NULL,
  `ymax_itemid` bigint(20) unsigned DEFAULT NULL,
  `flags` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`graphid`),
  KEY `graphs_graphs_1` (`name`),
  KEY `c_graphs_1` (`templateid`),
  KEY `c_graphs_2` (`ymin_itemid`),
  KEY `c_graphs_3` (`ymax_itemid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `graphs_items`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `graphs_items` (
  `gitemid` bigint(20) unsigned NOT NULL,
  `graphid` bigint(20) unsigned NOT NULL,
  `itemid` bigint(20) unsigned NOT NULL,
  `drawtype` int(11) NOT NULL DEFAULT '0',
  `sortorder` int(11) NOT NULL DEFAULT '0',
  `color` varchar(6) NOT NULL DEFAULT '009600',
  `yaxisside` int(11) NOT NULL DEFAULT '1',
  `calc_fnc` int(11) NOT NULL DEFAULT '2',
  `type` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`gitemid`),
  KEY `graphs_items_1` (`itemid`),
  KEY `graphs_items_2` (`graphid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `groups`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups` (
  `groupid` bigint(20) unsigned NOT NULL,
  `name` varchar(64) NOT NULL DEFAULT '',
  `internal` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`groupid`),
  KEY `groups_1` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `help_items`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `help_items` (
  `itemtype` int(11) NOT NULL DEFAULT '0',
  `key_` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`itemtype`,`key_`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `history`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `history` (
  `itemid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `value` double(20,4) NOT NULL DEFAULT '0.0000',
  `ns` int(11) NOT NULL DEFAULT '0',
  `hour` int(11) NOT NULL DEFAULT '0',
  KEY `history_1` (`itemid`,`clock`),
  KEY `history_2` (`hour`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `history_log`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `history_log` (
  `id` bigint(20) unsigned NOT NULL,
  `itemid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `timestamp` int(11) NOT NULL DEFAULT '0',
  `source` varchar(64) NOT NULL DEFAULT '',
  `severity` int(11) NOT NULL DEFAULT '0',
  `value` text NOT NULL,
  `logeventid` int(11) NOT NULL DEFAULT '0',
  `ns` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `history_log_2` (`itemid`,`id`),
  KEY `history_log_1` (`itemid`,`clock`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `history_str`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `history_str` (
  `itemid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `value` varchar(255) NOT NULL DEFAULT '',
  `ns` int(11) NOT NULL DEFAULT '0',
  KEY `history_str_1` (`itemid`,`clock`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `history_str_sync`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `history_str_sync` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nodeid` int(11) NOT NULL,
  `itemid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `value` varchar(255) NOT NULL DEFAULT '',
  `ns` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `history_str_sync_1` (`nodeid`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `history_sync`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `history_sync` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nodeid` int(11) NOT NULL,
  `itemid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `value` double(16,4) NOT NULL DEFAULT '0.0000',
  `ns` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `history_sync_1` (`nodeid`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `history_text`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `history_text` (
  `id` bigint(20) unsigned NOT NULL,
  `itemid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `value` text NOT NULL,
  `ns` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `history_text_2` (`itemid`,`id`),
  KEY `history_text_1` (`itemid`,`clock`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `history_uint`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `history_uint` (
  `itemid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `value` bigint(20) unsigned NOT NULL DEFAULT '0',
  `ns` int(11) NOT NULL DEFAULT '0',
  KEY `history_uint_1` (`itemid`,`clock`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `history_uint_sync`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `history_uint_sync` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nodeid` int(11) NOT NULL,
  `itemid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `value` bigint(20) unsigned NOT NULL DEFAULT '0',
  `ns` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `history_uint_sync_1` (`nodeid`,`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `host_inventory`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `host_inventory` (
  `hostid` bigint(20) unsigned NOT NULL,
  `inventory_mode` int(11) NOT NULL DEFAULT '0',
  `type` varchar(64) NOT NULL DEFAULT '',
  `type_full` varchar(64) NOT NULL DEFAULT '',
  `name` varchar(64) NOT NULL DEFAULT '',
  `alias` varchar(64) NOT NULL DEFAULT '',
  `os` varchar(64) NOT NULL DEFAULT '',
  `os_full` varchar(255) NOT NULL DEFAULT '',
  `os_short` varchar(64) NOT NULL DEFAULT '',
  `serialno_a` varchar(64) NOT NULL DEFAULT '',
  `serialno_b` varchar(64) NOT NULL DEFAULT '',
  `tag` varchar(64) NOT NULL DEFAULT '',
  `asset_tag` varchar(64) NOT NULL DEFAULT '',
  `macaddress_a` varchar(64) NOT NULL DEFAULT '',
  `macaddress_b` varchar(64) NOT NULL DEFAULT '',
  `hardware` varchar(255) NOT NULL DEFAULT '',
  `hardware_full` text NOT NULL,
  `software` varchar(255) NOT NULL DEFAULT '',
  `software_full` text NOT NULL,
  `software_app_a` varchar(64) NOT NULL DEFAULT '',
  `software_app_b` varchar(64) NOT NULL DEFAULT '',
  `software_app_c` varchar(64) NOT NULL DEFAULT '',
  `software_app_d` varchar(64) NOT NULL DEFAULT '',
  `software_app_e` varchar(64) NOT NULL DEFAULT '',
  `contact` text NOT NULL,
  `location` text NOT NULL,
  `location_lat` varchar(16) NOT NULL DEFAULT '',
  `location_lon` varchar(16) NOT NULL DEFAULT '',
  `notes` text NOT NULL,
  `chassis` varchar(64) NOT NULL DEFAULT '',
  `model` varchar(64) NOT NULL DEFAULT '',
  `hw_arch` varchar(32) NOT NULL DEFAULT '',
  `vendor` varchar(64) NOT NULL DEFAULT '',
  `contract_number` varchar(64) NOT NULL DEFAULT '',
  `installer_name` varchar(64) NOT NULL DEFAULT '',
  `deployment_status` varchar(64) NOT NULL DEFAULT '',
  `url_a` varchar(255) NOT NULL DEFAULT '',
  `url_b` varchar(255) NOT NULL DEFAULT '',
  `url_c` varchar(255) NOT NULL DEFAULT '',
  `host_networks` text NOT NULL,
  `host_netmask` varchar(39) NOT NULL DEFAULT '',
  `host_router` varchar(39) NOT NULL DEFAULT '',
  `oob_ip` varchar(39) NOT NULL DEFAULT '',
  `oob_netmask` varchar(39) NOT NULL DEFAULT '',
  `oob_router` varchar(39) NOT NULL DEFAULT '',
  `date_hw_purchase` varchar(64) NOT NULL DEFAULT '',
  `date_hw_install` varchar(64) NOT NULL DEFAULT '',
  `date_hw_expiry` varchar(64) NOT NULL DEFAULT '',
  `date_hw_decomm` varchar(64) NOT NULL DEFAULT '',
  `site_address_a` varchar(128) NOT NULL DEFAULT '',
  `site_address_b` varchar(128) NOT NULL DEFAULT '',
  `site_address_c` varchar(128) NOT NULL DEFAULT '',
  `site_city` varchar(128) NOT NULL DEFAULT '',
  `site_state` varchar(64) NOT NULL DEFAULT '',
  `site_country` varchar(64) NOT NULL DEFAULT '',
  `site_zip` varchar(64) NOT NULL DEFAULT '',
  `site_rack` varchar(128) NOT NULL DEFAULT '',
  `site_notes` text NOT NULL,
  `poc_1_name` varchar(128) NOT NULL DEFAULT '',
  `poc_1_email` varchar(128) NOT NULL DEFAULT '',
  `poc_1_phone_a` varchar(64) NOT NULL DEFAULT '',
  `poc_1_phone_b` varchar(64) NOT NULL DEFAULT '',
  `poc_1_cell` varchar(64) NOT NULL DEFAULT '',
  `poc_1_screen` varchar(64) NOT NULL DEFAULT '',
  `poc_1_notes` text NOT NULL,
  `poc_2_name` varchar(128) NOT NULL DEFAULT '',
  `poc_2_email` varchar(128) NOT NULL DEFAULT '',
  `poc_2_phone_a` varchar(64) NOT NULL DEFAULT '',
  `poc_2_phone_b` varchar(64) NOT NULL DEFAULT '',
  `poc_2_cell` varchar(64) NOT NULL DEFAULT '',
  `poc_2_screen` varchar(64) NOT NULL DEFAULT '',
  `poc_2_notes` text NOT NULL,
  PRIMARY KEY (`hostid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hostmacro`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hostmacro` (
  `hostmacroid` bigint(20) unsigned NOT NULL,
  `hostid` bigint(20) unsigned NOT NULL,
  `macro` varchar(64) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`hostmacroid`),
  UNIQUE KEY `hostmacro_1` (`hostid`,`macro`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hosts`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hosts` (
  `hostid` bigint(20) unsigned NOT NULL,
  `proxy_hostid` bigint(20) unsigned DEFAULT NULL,
  `host` varchar(64) NOT NULL DEFAULT '',
  `status` int(11) NOT NULL DEFAULT '0',
  `disable_until` int(11) NOT NULL DEFAULT '0',
  `error` varchar(128) NOT NULL DEFAULT '',
  `available` int(11) NOT NULL DEFAULT '0',
  `errors_from` int(11) NOT NULL DEFAULT '0',
  `lastaccess` int(11) NOT NULL DEFAULT '0',
  `ipmi_authtype` int(11) NOT NULL DEFAULT '0',
  `ipmi_privilege` int(11) NOT NULL DEFAULT '2',
  `ipmi_username` varchar(16) NOT NULL DEFAULT '',
  `ipmi_password` varchar(20) NOT NULL DEFAULT '',
  `ipmi_disable_until` int(11) NOT NULL DEFAULT '0',
  `ipmi_available` int(11) NOT NULL DEFAULT '0',
  `snmp_disable_until` int(11) NOT NULL DEFAULT '0',
  `snmp_available` int(11) NOT NULL DEFAULT '0',
  `maintenanceid` bigint(20) unsigned DEFAULT NULL,
  `maintenance_status` int(11) NOT NULL DEFAULT '0',
  `maintenance_type` int(11) NOT NULL DEFAULT '0',
  `maintenance_from` int(11) NOT NULL DEFAULT '0',
  `ipmi_errors_from` int(11) NOT NULL DEFAULT '0',
  `snmp_errors_from` int(11) NOT NULL DEFAULT '0',
  `ipmi_error` varchar(128) NOT NULL DEFAULT '',
  `snmp_error` varchar(128) NOT NULL DEFAULT '',
  `jmx_disable_until` int(11) NOT NULL DEFAULT '0',
  `jmx_available` int(11) NOT NULL DEFAULT '0',
  `jmx_errors_from` int(11) NOT NULL DEFAULT '0',
  `jmx_error` varchar(128) NOT NULL DEFAULT '',
  `name` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`hostid`),
  KEY `hosts_1` (`host`),
  KEY `hosts_2` (`status`),
  KEY `hosts_3` (`proxy_hostid`),
  KEY `hosts_4` (`name`),
  KEY `c_hosts_2` (`maintenanceid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hosts_groups`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hosts_groups` (
  `hostgroupid` bigint(20) unsigned NOT NULL,
  `hostid` bigint(20) unsigned NOT NULL,
  `groupid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`hostgroupid`),
  UNIQUE KEY `hosts_groups_1` (`hostid`,`groupid`),
  KEY `hosts_groups_2` (`groupid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hosts_templates`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hosts_templates` (
  `hosttemplateid` bigint(20) unsigned NOT NULL,
  `hostid` bigint(20) unsigned NOT NULL,
  `templateid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`hosttemplateid`),
  UNIQUE KEY `hosts_templates_1` (`hostid`,`templateid`),
  KEY `hosts_templates_2` (`templateid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `housekeeper`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `housekeeper` (
  `housekeeperid` bigint(20) unsigned NOT NULL,
  `tablename` varchar(64) NOT NULL DEFAULT '',
  `field` varchar(64) NOT NULL DEFAULT '',
  `value` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`housekeeperid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `httpstep`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `httpstep` (
  `httpstepid` bigint(20) unsigned NOT NULL,
  `httptestid` bigint(20) unsigned NOT NULL,
  `name` varchar(64) NOT NULL DEFAULT '',
  `no` int(11) NOT NULL DEFAULT '0',
  `url` varchar(255) NOT NULL DEFAULT '',
  `timeout` int(11) NOT NULL DEFAULT '30',
  `posts` text NOT NULL,
  `required` varchar(255) NOT NULL DEFAULT '',
  `status_codes` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`httpstepid`),
  KEY `httpstep_httpstep_1` (`httptestid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `httpstepitem`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `httpstepitem` (
  `httpstepitemid` bigint(20) unsigned NOT NULL,
  `httpstepid` bigint(20) unsigned NOT NULL,
  `itemid` bigint(20) unsigned NOT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`httpstepitemid`),
  UNIQUE KEY `httpstepitem_httpstepitem_1` (`httpstepid`,`itemid`),
  KEY `c_httpstepitem_2` (`itemid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `httptest`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `httptest` (
  `httptestid` bigint(20) unsigned NOT NULL,
  `name` varchar(64) NOT NULL DEFAULT '',
  `applicationid` bigint(20) unsigned NOT NULL,
  `nextcheck` int(11) NOT NULL DEFAULT '0',
  `delay` int(11) NOT NULL DEFAULT '60',
  `status` int(11) NOT NULL DEFAULT '0',
  `macros` text NOT NULL,
  `agent` varchar(255) NOT NULL DEFAULT '',
  `authentication` int(11) NOT NULL DEFAULT '0',
  `http_user` varchar(64) NOT NULL DEFAULT '',
  `http_password` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`httptestid`),
  KEY `httptest_httptest_1` (`applicationid`),
  KEY `httptest_2` (`name`),
  KEY `httptest_3` (`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `httptestitem`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `httptestitem` (
  `httptestitemid` bigint(20) unsigned NOT NULL,
  `httptestid` bigint(20) unsigned NOT NULL,
  `itemid` bigint(20) unsigned NOT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`httptestitemid`),
  UNIQUE KEY `httptestitem_httptestitem_1` (`httptestid`,`itemid`),
  KEY `c_httptestitem_2` (`itemid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `icon_map`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `icon_map` (
  `iconmapid` bigint(20) unsigned NOT NULL,
  `name` varchar(64) NOT NULL DEFAULT '',
  `default_iconid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`iconmapid`),
  KEY `icon_map_1` (`name`),
  KEY `c_icon_map_1` (`default_iconid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `icon_mapping`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `icon_mapping` (
  `iconmappingid` bigint(20) unsigned NOT NULL,
  `iconmapid` bigint(20) unsigned NOT NULL,
  `iconid` bigint(20) unsigned NOT NULL,
  `inventory_link` int(11) NOT NULL DEFAULT '0',
  `expression` varchar(64) NOT NULL DEFAULT '',
  `sortorder` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`iconmappingid`),
  KEY `icon_mapping_1` (`iconmapid`),
  KEY `c_icon_mapping_2` (`iconid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ids`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ids` (
  `nodeid` int(11) NOT NULL,
  `table_name` varchar(64) NOT NULL DEFAULT '',
  `field_name` varchar(64) NOT NULL DEFAULT '',
  `nextid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`nodeid`,`table_name`,`field_name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `images`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images` (
  `imageid` bigint(20) unsigned NOT NULL,
  `imagetype` int(11) NOT NULL DEFAULT '0',
  `name` varchar(64) NOT NULL DEFAULT '0',
  `image` longblob NOT NULL,
  PRIMARY KEY (`imageid`),
  KEY `images_1` (`imagetype`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interface`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `interface` (
  `interfaceid` bigint(20) unsigned NOT NULL,
  `hostid` bigint(20) unsigned NOT NULL,
  `main` int(11) NOT NULL DEFAULT '0',
  `type` int(11) NOT NULL DEFAULT '0',
  `useip` int(11) NOT NULL DEFAULT '1',
  `ip` varchar(39) NOT NULL DEFAULT '127.0.0.1',
  `dns` varchar(64) NOT NULL DEFAULT '',
  `port` varchar(64) NOT NULL DEFAULT '10050',
  PRIMARY KEY (`interfaceid`),
  KEY `interface_1` (`hostid`,`type`),
  KEY `interface_2` (`ip`,`dns`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_discovery`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_discovery` (
  `itemdiscoveryid` bigint(20) unsigned NOT NULL,
  `itemid` bigint(20) unsigned NOT NULL,
  `parent_itemid` bigint(20) unsigned NOT NULL,
  `key_` varchar(255) NOT NULL DEFAULT '',
  `lastcheck` int(11) NOT NULL DEFAULT '0',
  `ts_delete` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`itemdiscoveryid`),
  UNIQUE KEY `item_discovery_1` (`itemid`,`parent_itemid`),
  KEY `c_item_discovery_2` (`parent_itemid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `items`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items` (
  `itemid` bigint(20) unsigned NOT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  `snmp_community` varchar(64) NOT NULL DEFAULT '',
  `snmp_oid` varchar(255) NOT NULL DEFAULT '',
  `hostid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `key_` varchar(255) NOT NULL DEFAULT '',
  `delay` int(11) NOT NULL DEFAULT '0',
  `history` int(11) NOT NULL DEFAULT '90',
  `trends` int(11) NOT NULL DEFAULT '365',
  `lastvalue` varchar(255) DEFAULT NULL,
  `lastclock` int(11) DEFAULT NULL,
  `prevvalue` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '0',
  `value_type` int(11) NOT NULL DEFAULT '0',
  `trapper_hosts` varchar(255) NOT NULL DEFAULT '',
  `units` varchar(255) NOT NULL DEFAULT '',
  `multiplier` int(11) NOT NULL DEFAULT '0',
  `delta` int(11) NOT NULL DEFAULT '0',
  `prevorgvalue` varchar(255) DEFAULT NULL,
  `snmpv3_securityname` varchar(64) NOT NULL DEFAULT '',
  `snmpv3_securitylevel` int(11) NOT NULL DEFAULT '0',
  `snmpv3_authpassphrase` varchar(64) NOT NULL DEFAULT '',
  `snmpv3_privpassphrase` varchar(64) NOT NULL DEFAULT '',
  `formula` varchar(255) NOT NULL DEFAULT '1',
  `error` varchar(128) NOT NULL DEFAULT '',
  `lastlogsize` bigint(20) unsigned NOT NULL DEFAULT '0',
  `logtimefmt` varchar(64) NOT NULL DEFAULT '',
  `templateid` bigint(20) unsigned DEFAULT NULL,
  `valuemapid` bigint(20) unsigned DEFAULT NULL,
  `delay_flex` varchar(255) NOT NULL DEFAULT '',
  `params` text,
  `ipmi_sensor` varchar(128) NOT NULL DEFAULT '',
  `data_type` int(11) NOT NULL DEFAULT '0',
  `authtype` int(11) NOT NULL DEFAULT '0',
  `username` varchar(64) NOT NULL DEFAULT '',
  `password` varchar(64) NOT NULL DEFAULT '',
  `publickey` varchar(64) NOT NULL DEFAULT '',
  `privatekey` varchar(64) NOT NULL DEFAULT '',
  `mtime` int(11) NOT NULL DEFAULT '0',
  `lastns` int(11) DEFAULT NULL,
  `flags` int(11) NOT NULL DEFAULT '0',
  `filter` varchar(255) NOT NULL DEFAULT '',
  `interfaceid` bigint(20) unsigned DEFAULT NULL,
  `port` varchar(64) NOT NULL DEFAULT '',
  `description` text,
  `inventory_link` int(11) NOT NULL DEFAULT '0',
  `lifetime` varchar(64) NOT NULL DEFAULT '30',
  `collectorid` bigint(20) unsigned DEFAULT NULL,
  `ruleid` bigint(20) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`itemid`),
  UNIQUE KEY `items_1` (`hostid`,`key_`),
  KEY `items_3` (`status`),
  KEY `items_4` (`templateid`),
  KEY `items_5` (`valuemapid`),
  KEY `c_items_4` (`interfaceid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `items_applications`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items_applications` (
  `itemappid` bigint(20) unsigned NOT NULL,
  `applicationid` bigint(20) unsigned NOT NULL,
  `itemid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`itemappid`),
  UNIQUE KEY `items_applications_1` (`applicationid`,`itemid`),
  KEY `items_applications_2` (`itemid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `maintenances`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `maintenances` (
  `maintenanceid` bigint(20) unsigned NOT NULL,
  `name` varchar(128) NOT NULL DEFAULT '',
  `maintenance_type` int(11) NOT NULL DEFAULT '0',
  `description` text NOT NULL,
  `active_since` int(11) NOT NULL DEFAULT '0',
  `active_till` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`maintenanceid`),
  KEY `maintenances_1` (`active_since`,`active_till`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `maintenances_groups`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `maintenances_groups` (
  `maintenance_groupid` bigint(20) unsigned NOT NULL,
  `maintenanceid` bigint(20) unsigned NOT NULL,
  `groupid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`maintenance_groupid`),
  UNIQUE KEY `maintenances_groups_1` (`maintenanceid`,`groupid`),
  KEY `c_maintenances_groups_2` (`groupid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `maintenances_hosts`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `maintenances_hosts` (
  `maintenance_hostid` bigint(20) unsigned NOT NULL,
  `maintenanceid` bigint(20) unsigned NOT NULL,
  `hostid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`maintenance_hostid`),
  UNIQUE KEY `maintenances_hosts_1` (`maintenanceid`,`hostid`),
  KEY `c_maintenances_hosts_2` (`hostid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `maintenances_windows`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `maintenances_windows` (
  `maintenance_timeperiodid` bigint(20) unsigned NOT NULL,
  `maintenanceid` bigint(20) unsigned NOT NULL,
  `timeperiodid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`maintenance_timeperiodid`),
  UNIQUE KEY `maintenances_windows_1` (`maintenanceid`,`timeperiodid`),
  KEY `c_maintenances_windows_2` (`timeperiodid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mappings`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mappings` (
  `mappingid` bigint(20) unsigned NOT NULL,
  `valuemapid` bigint(20) unsigned NOT NULL,
  `value` varchar(64) NOT NULL DEFAULT '',
  `newvalue` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`mappingid`),
  KEY `mappings_1` (`valuemapid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `media`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `media` (
  `mediaid` bigint(20) unsigned NOT NULL,
  `userid` bigint(20) unsigned NOT NULL,
  `mediatypeid` bigint(20) unsigned NOT NULL,
  `sendto` varchar(100) NOT NULL DEFAULT '',
  `active` int(11) NOT NULL DEFAULT '0',
  `severity` int(11) NOT NULL DEFAULT '63',
  `period` varchar(100) NOT NULL DEFAULT '1-7,00:00-24:00',
  PRIMARY KEY (`mediaid`),
  KEY `media_1` (`userid`),
  KEY `media_2` (`mediatypeid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `media_type`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `media_type` (
  `mediatypeid` bigint(20) unsigned NOT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  `description` varchar(100) NOT NULL DEFAULT '',
  `smtp_server` varchar(255) NOT NULL DEFAULT '',
  `smtp_helo` varchar(255) NOT NULL DEFAULT '',
  `smtp_email` varchar(255) NOT NULL DEFAULT '',
  `exec_path` varchar(255) NOT NULL DEFAULT '',
  `gsm_modem` varchar(255) NOT NULL DEFAULT '',
  `username` varchar(255) NOT NULL DEFAULT '',
  `passwd` varchar(255) NOT NULL DEFAULT '',
  `status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`mediatypeid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `node_cksum`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `node_cksum` (
  `nodeid` int(11) NOT NULL,
  `tablename` varchar(64) NOT NULL DEFAULT '',
  `recordid` bigint(20) unsigned NOT NULL,
  `cksumtype` int(11) NOT NULL DEFAULT '0',
  `cksum` text NOT NULL,
  `sync` char(128) NOT NULL DEFAULT '',
  KEY `node_cksum_1` (`nodeid`,`cksumtype`,`tablename`,`recordid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `nodes`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nodes` (
  `nodeid` int(11) NOT NULL,
  `name` varchar(64) NOT NULL DEFAULT '0',
  `ip` varchar(39) NOT NULL DEFAULT '',
  `port` int(11) NOT NULL DEFAULT '10051',
  `nodetype` int(11) NOT NULL DEFAULT '0',
  `masterid` int(11) DEFAULT NULL,
  PRIMARY KEY (`nodeid`),
  KEY `c_nodes_1` (`masterid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opcommand`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opcommand` (
  `operationid` bigint(20) unsigned NOT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  `scriptid` bigint(20) unsigned DEFAULT NULL,
  `execute_on` int(11) NOT NULL DEFAULT '0',
  `port` varchar(64) NOT NULL DEFAULT '',
  `authtype` int(11) NOT NULL DEFAULT '0',
  `username` varchar(64) NOT NULL DEFAULT '',
  `password` varchar(64) NOT NULL DEFAULT '',
  `publickey` varchar(64) NOT NULL DEFAULT '',
  `privatekey` varchar(64) NOT NULL DEFAULT '',
  `command` text NOT NULL,
  PRIMARY KEY (`operationid`),
  KEY `c_opcommand_2` (`scriptid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opcommand_grp`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opcommand_grp` (
  `opcommand_grpid` bigint(20) unsigned NOT NULL,
  `operationid` bigint(20) unsigned NOT NULL,
  `groupid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`opcommand_grpid`),
  KEY `opcommand_grp_1` (`operationid`),
  KEY `c_opcommand_grp_2` (`groupid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opcommand_hst`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opcommand_hst` (
  `opcommand_hstid` bigint(20) unsigned NOT NULL,
  `operationid` bigint(20) unsigned NOT NULL,
  `hostid` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`opcommand_hstid`),
  KEY `opcommand_hst_1` (`operationid`),
  KEY `c_opcommand_hst_2` (`hostid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opconditions`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opconditions` (
  `opconditionid` bigint(20) unsigned NOT NULL,
  `operationid` bigint(20) unsigned NOT NULL,
  `conditiontype` int(11) NOT NULL DEFAULT '0',
  `operator` int(11) NOT NULL DEFAULT '0',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`opconditionid`),
  KEY `opconditions_1` (`operationid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `operations`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operations` (
  `operationid` bigint(20) unsigned NOT NULL,
  `actionid` bigint(20) unsigned NOT NULL,
  `operationtype` int(11) NOT NULL DEFAULT '0',
  `esc_period` int(11) NOT NULL DEFAULT '0',
  `esc_step_from` int(11) NOT NULL DEFAULT '1',
  `esc_step_to` int(11) NOT NULL DEFAULT '1',
  `evaltype` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`operationid`),
  KEY `operations_1` (`actionid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opgroup`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opgroup` (
  `opgroupid` bigint(20) unsigned NOT NULL,
  `operationid` bigint(20) unsigned NOT NULL,
  `groupid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`opgroupid`),
  UNIQUE KEY `opgroup_1` (`operationid`,`groupid`),
  KEY `c_opgroup_2` (`groupid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opmessage`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opmessage` (
  `operationid` bigint(20) unsigned NOT NULL,
  `default_msg` int(11) NOT NULL DEFAULT '0',
  `subject` varchar(255) NOT NULL DEFAULT '',
  `message` text NOT NULL,
  `mediatypeid` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`operationid`),
  KEY `c_opmessage_2` (`mediatypeid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opmessage_grp`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opmessage_grp` (
  `opmessage_grpid` bigint(20) unsigned NOT NULL,
  `operationid` bigint(20) unsigned NOT NULL,
  `usrgrpid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`opmessage_grpid`),
  UNIQUE KEY `opmessage_grp_1` (`operationid`,`usrgrpid`),
  KEY `c_opmessage_grp_2` (`usrgrpid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opmessage_usr`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opmessage_usr` (
  `opmessage_usrid` bigint(20) unsigned NOT NULL,
  `operationid` bigint(20) unsigned NOT NULL,
  `userid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`opmessage_usrid`),
  UNIQUE KEY `opmessage_usr_1` (`operationid`,`userid`),
  KEY `c_opmessage_usr_2` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `optemplate`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `optemplate` (
  `optemplateid` bigint(20) unsigned NOT NULL,
  `operationid` bigint(20) unsigned NOT NULL,
  `templateid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`optemplateid`),
  UNIQUE KEY `optemplate_1` (`operationid`,`templateid`),
  KEY `c_optemplate_2` (`templateid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `profiles`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profiles` (
  `profileid` bigint(20) unsigned NOT NULL,
  `userid` bigint(20) unsigned NOT NULL,
  `idx` varchar(96) NOT NULL DEFAULT '',
  `idx2` bigint(20) unsigned NOT NULL DEFAULT '0',
  `value_id` bigint(20) unsigned NOT NULL DEFAULT '0',
  `value_int` int(11) NOT NULL DEFAULT '0',
  `value_str` varchar(255) NOT NULL DEFAULT '',
  `source` varchar(96) NOT NULL DEFAULT '',
  `type` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`profileid`),
  KEY `profiles_1` (`userid`,`idx`,`idx2`),
  KEY `profiles_2` (`userid`,`profileid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `proxy_autoreg_host`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proxy_autoreg_host` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `clock` int(11) NOT NULL DEFAULT '0',
  `host` varchar(64) NOT NULL DEFAULT '',
  `listen_ip` varchar(39) NOT NULL DEFAULT '',
  `listen_port` int(11) NOT NULL DEFAULT '0',
  `listen_dns` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `proxy_autoreg_host_1` (`clock`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `proxy_dhistory`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proxy_dhistory` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `clock` int(11) NOT NULL DEFAULT '0',
  `druleid` bigint(20) unsigned NOT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  `ip` varchar(39) NOT NULL DEFAULT '',
  `port` int(11) NOT NULL DEFAULT '0',
  `key_` varchar(255) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  `status` int(11) NOT NULL DEFAULT '0',
  `dcheckid` bigint(20) unsigned DEFAULT NULL,
  `dns` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `proxy_dhistory_1` (`clock`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `proxy_history`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proxy_history` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `itemid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `timestamp` int(11) NOT NULL DEFAULT '0',
  `source` varchar(64) NOT NULL DEFAULT '',
  `severity` int(11) NOT NULL DEFAULT '0',
  `value` longtext NOT NULL,
  `logeventid` int(11) NOT NULL DEFAULT '0',
  `ns` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`),
  KEY `proxy_history_1` (`clock`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `regexps`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `regexps` (
  `regexpid` bigint(20) unsigned NOT NULL,
  `name` varchar(128) NOT NULL DEFAULT '',
  `test_string` text NOT NULL,
  PRIMARY KEY (`regexpid`),
  KEY `regexps_1` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `rights`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rights` (
  `rightid` bigint(20) unsigned NOT NULL,
  `groupid` bigint(20) unsigned NOT NULL,
  `permission` int(11) NOT NULL DEFAULT '0',
  `id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`rightid`),
  KEY `rights_1` (`groupid`),
  KEY `rights_2` (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `screens`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `screens` (
  `screenid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `hsize` int(11) NOT NULL DEFAULT '1',
  `vsize` int(11) NOT NULL DEFAULT '1',
  `templateid` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`screenid`),
  KEY `c_screens_1` (`templateid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `screens_items`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `screens_items` (
  `screenitemid` bigint(20) unsigned NOT NULL,
  `screenid` bigint(20) unsigned NOT NULL,
  `resourcetype` int(11) NOT NULL DEFAULT '0',
  `resourceid` bigint(20) unsigned NOT NULL DEFAULT '0',
  `width` int(11) NOT NULL DEFAULT '320',
  `height` int(11) NOT NULL DEFAULT '200',
  `x` int(11) NOT NULL DEFAULT '0',
  `y` int(11) NOT NULL DEFAULT '0',
  `colspan` int(11) NOT NULL DEFAULT '0',
  `rowspan` int(11) NOT NULL DEFAULT '0',
  `elements` int(11) NOT NULL DEFAULT '25',
  `valign` int(11) NOT NULL DEFAULT '0',
  `halign` int(11) NOT NULL DEFAULT '0',
  `style` int(11) NOT NULL DEFAULT '0',
  `url` varchar(255) NOT NULL DEFAULT '',
  `dynamic` int(11) NOT NULL DEFAULT '0',
  `sort_triggers` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`screenitemid`),
  KEY `c_screens_items_1` (`screenid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `scripts`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scripts` (
  `scriptid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `command` varchar(255) NOT NULL DEFAULT '',
  `host_access` int(11) NOT NULL DEFAULT '2',
  `usrgrpid` bigint(20) unsigned DEFAULT NULL,
  `groupid` bigint(20) unsigned DEFAULT NULL,
  `description` text NOT NULL,
  `confirmation` varchar(255) NOT NULL DEFAULT '',
  `type` int(11) NOT NULL DEFAULT '0',
  `execute_on` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`scriptid`),
  KEY `c_scripts_1` (`usrgrpid`),
  KEY `c_scripts_2` (`groupid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_alarms`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_alarms` (
  `servicealarmid` bigint(20) unsigned NOT NULL,
  `serviceid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `value` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`servicealarmid`),
  KEY `service_alarms_1` (`serviceid`,`clock`),
  KEY `service_alarms_2` (`clock`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `services`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `services` (
  `serviceid` bigint(20) unsigned NOT NULL,
  `name` varchar(128) NOT NULL DEFAULT '',
  `status` int(11) NOT NULL DEFAULT '0',
  `algorithm` int(11) NOT NULL DEFAULT '0',
  `triggerid` bigint(20) unsigned DEFAULT NULL,
  `showsla` int(11) NOT NULL DEFAULT '0',
  `goodsla` double(16,4) NOT NULL DEFAULT '99.9000',
  `sortorder` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`serviceid`),
  KEY `services_1` (`triggerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `services_links`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `services_links` (
  `linkid` bigint(20) unsigned NOT NULL,
  `serviceupid` bigint(20) unsigned NOT NULL,
  `servicedownid` bigint(20) unsigned NOT NULL,
  `soft` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`linkid`),
  UNIQUE KEY `services_links_links_2` (`serviceupid`,`servicedownid`),
  KEY `services_links_links_1` (`servicedownid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `services_times`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `services_times` (
  `timeid` bigint(20) unsigned NOT NULL,
  `serviceid` bigint(20) unsigned NOT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  `ts_from` int(11) NOT NULL DEFAULT '0',
  `ts_to` int(11) NOT NULL DEFAULT '0',
  `note` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`timeid`),
  KEY `services_times_times_1` (`serviceid`,`type`,`ts_from`,`ts_to`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `sessionid` varchar(32) NOT NULL DEFAULT '',
  `userid` bigint(20) unsigned NOT NULL,
  `lastaccess` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`sessionid`),
  KEY `sessions_1` (`userid`,`status`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `slides`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `slides` (
  `slideid` bigint(20) unsigned NOT NULL,
  `slideshowid` bigint(20) unsigned NOT NULL,
  `screenid` bigint(20) unsigned NOT NULL,
  `step` int(11) NOT NULL DEFAULT '0',
  `delay` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`slideid`),
  KEY `slides_slides_1` (`slideshowid`),
  KEY `c_slides_2` (`screenid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `slideshows`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `slideshows` (
  `slideshowid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `delay` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`slideshowid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sysmap_element_url`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sysmap_element_url` (
  `sysmapelementurlid` bigint(20) unsigned NOT NULL,
  `selementid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`sysmapelementurlid`),
  UNIQUE KEY `sysmap_element_url_1` (`selementid`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sysmap_url`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sysmap_url` (
  `sysmapurlid` bigint(20) unsigned NOT NULL,
  `sysmapid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL DEFAULT '',
  `elementtype` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`sysmapurlid`),
  UNIQUE KEY `sysmap_url_1` (`sysmapid`,`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sysmaps`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sysmaps` (
  `sysmapid` bigint(20) unsigned NOT NULL,
  `name` varchar(128) NOT NULL DEFAULT '',
  `width` int(11) NOT NULL DEFAULT '600',
  `height` int(11) NOT NULL DEFAULT '400',
  `backgroundid` bigint(20) unsigned DEFAULT NULL,
  `label_type` int(11) NOT NULL DEFAULT '2',
  `label_location` int(11) NOT NULL DEFAULT '3',
  `highlight` int(11) NOT NULL DEFAULT '1',
  `expandproblem` int(11) NOT NULL DEFAULT '1',
  `markelements` int(11) NOT NULL DEFAULT '0',
  `show_unack` int(11) NOT NULL DEFAULT '0',
  `grid_show` int(11) NOT NULL DEFAULT '1',
  `grid_align` int(11) NOT NULL DEFAULT '1',
  `label_format` int(11) NOT NULL DEFAULT '0',
  `label_type_host` int(11) NOT NULL DEFAULT '2',
  `label_type_hostgroup` int(11) NOT NULL DEFAULT '2',
  `label_type_trigger` int(11) NOT NULL DEFAULT '2',
  `label_type_map` int(11) NOT NULL DEFAULT '2',
  `label_type_image` int(11) NOT NULL DEFAULT '2',
  `label_string_host` varchar(255) NOT NULL DEFAULT '',
  `label_string_hostgroup` varchar(255) NOT NULL DEFAULT '',
  `label_string_trigger` varchar(255) NOT NULL DEFAULT '',
  `label_string_map` varchar(255) NOT NULL DEFAULT '',
  `label_string_image` varchar(255) NOT NULL DEFAULT '',
  `iconmapid` bigint(20) unsigned DEFAULT NULL,
  `expand_macros` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`sysmapid`),
  KEY `sysmaps_1` (`name`),
  KEY `c_sysmaps_1` (`backgroundid`),
  KEY `c_sysmaps_2` (`iconmapid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sysmaps_elements`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sysmaps_elements` (
  `selementid` bigint(20) unsigned NOT NULL,
  `sysmapid` bigint(20) unsigned NOT NULL,
  `elementid` bigint(20) unsigned NOT NULL DEFAULT '0',
  `elementtype` int(11) NOT NULL DEFAULT '0',
  `iconid_off` bigint(20) unsigned DEFAULT NULL,
  `iconid_on` bigint(20) unsigned DEFAULT NULL,
  `label` varchar(255) NOT NULL DEFAULT '',
  `label_location` int(11) DEFAULT NULL,
  `x` int(11) NOT NULL DEFAULT '0',
  `y` int(11) NOT NULL DEFAULT '0',
  `iconid_disabled` bigint(20) unsigned DEFAULT NULL,
  `iconid_maintenance` bigint(20) unsigned DEFAULT NULL,
  `elementsubtype` int(11) NOT NULL DEFAULT '0',
  `areatype` int(11) NOT NULL DEFAULT '0',
  `width` int(11) NOT NULL DEFAULT '200',
  `height` int(11) NOT NULL DEFAULT '200',
  `viewtype` int(11) NOT NULL DEFAULT '0',
  `use_iconmap` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`selementid`),
  KEY `c_sysmaps_elements_1` (`sysmapid`),
  KEY `c_sysmaps_elements_2` (`iconid_off`),
  KEY `c_sysmaps_elements_3` (`iconid_on`),
  KEY `c_sysmaps_elements_4` (`iconid_disabled`),
  KEY `c_sysmaps_elements_5` (`iconid_maintenance`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sysmaps_link_triggers`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sysmaps_link_triggers` (
  `linktriggerid` bigint(20) unsigned NOT NULL,
  `linkid` bigint(20) unsigned NOT NULL,
  `triggerid` bigint(20) unsigned NOT NULL,
  `drawtype` int(11) NOT NULL DEFAULT '0',
  `color` varchar(6) NOT NULL DEFAULT '000000',
  PRIMARY KEY (`linktriggerid`),
  UNIQUE KEY `sysmaps_link_triggers_1` (`linkid`,`triggerid`),
  KEY `c_sysmaps_link_triggers_2` (`triggerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sysmaps_links`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sysmaps_links` (
  `linkid` bigint(20) unsigned NOT NULL,
  `sysmapid` bigint(20) unsigned NOT NULL,
  `selementid1` bigint(20) unsigned NOT NULL,
  `selementid2` bigint(20) unsigned NOT NULL,
  `drawtype` int(11) NOT NULL DEFAULT '0',
  `color` varchar(6) NOT NULL DEFAULT '000000',
  `label` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`linkid`),
  KEY `c_sysmaps_links_1` (`sysmapid`),
  KEY `c_sysmaps_links_2` (`selementid1`),
  KEY `c_sysmaps_links_3` (`selementid2`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `timeperiods`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `timeperiods` (
  `timeperiodid` bigint(20) unsigned NOT NULL,
  `timeperiod_type` int(11) NOT NULL DEFAULT '0',
  `every` int(11) NOT NULL DEFAULT '0',
  `month` int(11) NOT NULL DEFAULT '0',
  `dayofweek` int(11) NOT NULL DEFAULT '0',
  `day` int(11) NOT NULL DEFAULT '0',
  `start_time` int(11) NOT NULL DEFAULT '0',
  `period` int(11) NOT NULL DEFAULT '0',
  `start_date` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`timeperiodid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trends`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trends` (
  `itemid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `num` int(11) NOT NULL DEFAULT '0',
  `value_min` double(16,4) NOT NULL DEFAULT '0.0000',
  `value_avg` double(16,4) NOT NULL DEFAULT '0.0000',
  `value_max` double(16,4) NOT NULL DEFAULT '0.0000',
  PRIMARY KEY (`itemid`,`clock`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trends_uint`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trends_uint` (
  `itemid` bigint(20) unsigned NOT NULL,
  `clock` int(11) NOT NULL DEFAULT '0',
  `num` int(11) NOT NULL DEFAULT '0',
  `value_min` bigint(20) unsigned NOT NULL DEFAULT '0',
  `value_avg` bigint(20) unsigned NOT NULL DEFAULT '0',
  `value_max` bigint(20) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`itemid`,`clock`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trigger_depends`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trigger_depends` (
  `triggerdepid` bigint(20) unsigned NOT NULL,
  `triggerid_down` bigint(20) unsigned NOT NULL,
  `triggerid_up` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`triggerdepid`),
  UNIQUE KEY `trigger_depends_1` (`triggerid_down`,`triggerid_up`),
  KEY `trigger_depends_2` (`triggerid_up`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trigger_discovery`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trigger_discovery` (
  `triggerdiscoveryid` bigint(20) unsigned NOT NULL,
  `triggerid` bigint(20) unsigned NOT NULL,
  `parent_triggerid` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`triggerdiscoveryid`),
  UNIQUE KEY `trigger_discovery_1` (`triggerid`,`parent_triggerid`),
  KEY `c_trigger_discovery_2` (`parent_triggerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `triggers`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `triggers` (
  `triggerid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `expression` varchar(255) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  `url` varchar(255) NOT NULL DEFAULT '',
  `status` int(11) NOT NULL DEFAULT '0',
  `value` int(11) NOT NULL DEFAULT '0',
  `priority` int(11) NOT NULL DEFAULT '0',
  `lastchange` int(11) NOT NULL DEFAULT '0',
  `comments` text NOT NULL,
  `error` varchar(128) NOT NULL DEFAULT '',
  `templateid` bigint(20) unsigned DEFAULT NULL,
  `type` int(11) NOT NULL DEFAULT '0',
  `value_flags` int(11) NOT NULL DEFAULT '0',
  `flags` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`triggerid`),
  KEY `triggers_1` (`status`),
  KEY `triggers_2` (`value`),
  KEY `c_triggers_1` (`templateid`)
) ENGINE=MyISAM AUTO_INCREMENT=13528 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_history`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_history` (
  `userhistoryid` bigint(20) unsigned NOT NULL,
  `userid` bigint(20) unsigned NOT NULL,
  `title1` varchar(255) NOT NULL DEFAULT '',
  `url1` varchar(255) NOT NULL DEFAULT '',
  `title2` varchar(255) NOT NULL DEFAULT '',
  `url2` varchar(255) NOT NULL DEFAULT '',
  `title3` varchar(255) NOT NULL DEFAULT '',
  `url3` varchar(255) NOT NULL DEFAULT '',
  `title4` varchar(255) NOT NULL DEFAULT '',
  `url4` varchar(255) NOT NULL DEFAULT '',
  `title5` varchar(255) NOT NULL DEFAULT '',
  `url5` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`userhistoryid`),
  UNIQUE KEY `user_history_1` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `userid` bigint(20) unsigned NOT NULL,
  `alias` varchar(100) NOT NULL DEFAULT '',
  `name` varchar(100) NOT NULL DEFAULT '',
  `surname` varchar(100) NOT NULL DEFAULT '',
  `passwd` char(32) NOT NULL DEFAULT '',
  `url` varchar(255) NOT NULL DEFAULT '',
  `autologin` int(11) NOT NULL DEFAULT '0',
  `autologout` int(11) NOT NULL DEFAULT '900',
  `lang` varchar(5) NOT NULL DEFAULT 'en_GB',
  `refresh` int(11) NOT NULL DEFAULT '30',
  `type` int(11) NOT NULL DEFAULT '0',
  `theme` varchar(128) NOT NULL DEFAULT 'default',
  `attempt_failed` int(11) NOT NULL DEFAULT '0',
  `attempt_ip` varchar(39) NOT NULL DEFAULT '',
  `attempt_clock` int(11) NOT NULL DEFAULT '0',
  `rows_per_page` int(11) NOT NULL DEFAULT '50',
  PRIMARY KEY (`userid`),
  KEY `users_1` (`alias`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users_groups`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_groups` (
  `id` bigint(20) unsigned NOT NULL,
  `usrgrpid` bigint(20) unsigned NOT NULL,
  `userid` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_groups_1` (`usrgrpid`,`userid`),
  KEY `c_users_groups_2` (`userid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `usrgrp`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usrgrp` (
  `usrgrpid` bigint(20) unsigned NOT NULL,
  `name` varchar(64) NOT NULL DEFAULT '',
  `gui_access` int(11) NOT NULL DEFAULT '0',
  `users_status` int(11) NOT NULL DEFAULT '0',
  `debug_mode` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`usrgrpid`),
  KEY `usrgrp_1` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `valuemaps`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `valuemaps` (
  `valuemapid` bigint(20) unsigned NOT NULL,
  `name` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`valuemapid`),
  KEY `valuemaps_1` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-04-29 22:53:11


-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: 127.0.0.1    Database: zabbix
-- ------------------------------------------------------
-- Server version	5.6.24

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `rules`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rules` (
  `ruleid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pattern1` varchar(255) NOT NULL,
  `pattern2` varchar(255) NOT NULL,
  `aggregator` varchar(255) NOT NULL DEFAULT '',
  `app` varchar(255) NOT NULL,
  `os` varchar(255) DEFAULT '',
  `units` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`ruleid`),
  KEY `app` (`app`)
) ENGINE=InnoDB AUTO_INCREMENT=1735 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rules`
--

LOCK TABLES `rules` WRITE;
/*!40000 ALTER TABLE `rules` DISABLE KEYS */;
INSERT INTO `rules` VALUES (1203,'TCPv4','Connections Reset','','network','',''),(1204,'TCPv4','Segments Received/sec','','network','',''),(1205,'TCPv4','Segments Retransmitted/sec','','network','',''),(1206,'TCPv4','Connection Failures','','network','',''),(1207,'TCPv4','Segments Sent/sec','','network','',''),(1208,'TCPv4','Segments/sec','','network','',''),(1209,'Network Interface','Bytes Total/sec','*','network','',''),(1210,'Network Interface','Bytes Sent/sec','*','network','',''),(1211,'Network Interface','Bytes Received/sec','*','network','',''),(1212,'PhysicalDisk','Current Disk Queue Length','_Total','disk','',''),(1213,'PhysicalDisk','Avg. Disk Bytes/Read','_Total','disk','',''),(1214,'PhysicalDisk','Disk Read Bytes/sec','_Total','disk','',''),(1215,'LogicalDisk','Disk Read Bytes/sec','_Total','disk','',''),(1216,'PhysicalDisk','% Disk Time','_Total','disk','','%'),(1217,'PhysicalDisk','Avg. Disk Queue Length','_Total','disk','',''),(1218,'PhysicalDisk','Avg. Disk sec/Read','_Total','disk','',''),(1219,'PhysicalDisk','Disk Reads/sec','_Total','disk','',''),(1220,'NTDS','LDAP Active Threads','','activedirectory','',''),(1221,'NTDS','LDAP Bind Time','','activedirectory','',''),(1222,'NTDS','LDAP Client Sessions','','activedirectory','',''),(1223,'NTDS','DS Threads in Use','','activedirectory','',''),(1224,'NTDS','AB Client Sessions','','activedirectory','',''),(1225,'NTDS','DS Notify Queue Size','','activedirectory','',''),(1226,'NTDS','DRA Inbound Full Sync Objects Remaining','','activedirectory','',''),(1227,'NTDS','DRA Inbound Values (DNs only)/sec','','activedirectory','',''),(1228,'NTDS','DRA Outbound Values (DNs only)/sec','','activedirectory','',''),(1229,'NTDS','LDAP Successful Binds/sec','','activedirectory','',''),(1230,'NTDS','LDAP Searches/sec','','activedirectory','',''),(1231,'NTDS','DS Directory Reads/sec','','activedirectory','',''),(1232,'NTDS','DS Directory Writes/sec','','activedirectory','',''),(1233,'NTDS','DRA Pending Replication Synchronizations','','activedirectory','',''),(1234,'Memory','Page Faults/sec','','memory','',''),(1235,'Memory','Pages Input/sec','','memory','',''),(1236,'Memory','Pages Output/sec','','memory','',''),(1237,'Memory','Pages/sec','','memory','',''),(1238,'Memory','Page Reads/sec','','memory','',''),(1239,'Memory','Page Writes/sec','','memory','',''),(1240,'Memory','Committed Bytes','','memory','',''),(1241,'Process','Page Faults/sec','_Total','memory','',''),(1242,'Process','Pool Paged Bytes','_Total','memory','',''),(1243,'Process','Pool NonPaged Bytes','_Total','memory','',''),(1244,'Process','Working Set','_Total','memory','',''),(1245,'Paging File','% Usage','_Total','memory','','%'),(1246,'Paging File','% Usage Peak','_Total','memory','','%'),(1247,'Processor','% Processor Time','_Total','cpu','','%'),(1248,'Processor','Interrupts/sec','_Total','cpu','',''),(1249,'Processor','% Interrupt Time','_Total','cpu','','%'),(1250,'Processor','% User Time','_Total','cpu','','%'),(1251,'Processor','% Privileged Time','_Total','cpu','','%'),(1252,'Processor','% DPC Time','_Total','cpu','','%'),(1253,'Processor','DPCs Queued/sec','_Total','cpu','',''),(1254,'System','Processor Queue Length','','cpu','',''),(1255,'System','System Calls/sec','','cpu','',''),(1256,'Web Service','Bytes Total/sec','_Total','iis','win2k3',''),(1257,'Web Service','Total Method Requests/sec','_Total','iis','win2k3',''),(1258,'Web Service','Current Connections','_Total','iis','win2k3',''),(1259,'Web Service Cache','File Cache Hits %','','iis','win2k3','%'),(1260,'Web Service Cache','Kernel: URI Cache Flushes','','iis','win2k3',''),(1261,'Web Service Cache','Kernel: URI Cache Misses','','iis','win2k3',''),(1262,'Web Service Cache','Kernel: URI Cache Hits %','','iis','win2k3','%'),(1263,'Active Server Pages','Request Wait Time','','iis','win2k3',''),(1264,'Active Server Pages','Requests Queued','','iis','win2k3',''),(1265,'Active Server Pages','Transactions/Sec','','iis','win2k3',''),(1266,'SQLServer:Access Methods','Full Scans/sec','','sql','win2k8r2',''),(1267,'SQLServer:Access Methods','Index Searches/sec','','sql','win2k8r2',''),(1268,'SQLServer:Buffer Manager','Buffer cache hit ratio','','sql','win2k8r2',''),(1269,'SQLServer:Buffer Manager','Lazy writes/sec','','sql','win2k8r2',''),(1270,'SQLServer:Buffer Manager','Page life expectancy','','sql','win2k8r2',''),(1271,'SQLServer:Plan Cache','Cache pages','_Total','sql','win2k8r2',''),(1272,'SQLServer:Buffer Manager','Total Pages','','sql','win2k8r2',''),(1273,'SQLServer:Databases','Log Flushes/sec','_Total','sql','win2k8r2',''),(1274,'SQLServer:Databases','Transactions/sec','_Total','sql','win2k8r2',''),(1275,'SQLServer:Latches','Average Latch Wait Time (ms)','','sql','win2k8r2',''),(1276,'SQLServer:Latches','Latch Waits/sec','','sql','win2k8r2',''),(1277,'SQLServer:Latches','Total Latch Wait Time (ms)','','sql','win2k8r2',''),(1278,'SQLServer:Memory Manager','Target Server Memory (KB)','','sql','win2k8r2',''),(1279,'SQLServer:Memory Manager','Total Server Memory (KB)','','sql','win2k8r2',''),(1280,'SQLServer:SQL Statistics','Batch Requests/sec','','sql','win2k8r2',''),(1281,'SQLServer:SQL Statistics','SQL Compilations/sec','','sql','win2k8r2',''),(1282,'SQLServer:SQL Statistics','SQL Re-compilations/sec','','sql','win2k8r2',''),(1283,'.NET CLR Memory','# Total committed Bytes','*','iis','win2k8',''),(1284,'.NET CLR Exceptions','# of Exceps Thrown / sec','*','iis','win2k8',''),(1285,'ASP.NET','Application Restarts','','iis','win2k8',''),(1286,'ASP.NET','Requests Queued','','iis','win2k8',''),(1287,'ASP.NET Applications','Requests/Sec','*','iis','win2k8',''),(1288,'Web Service','Current Connections','_Total','iis','win2k8',''),(1289,'Web Service','Get Requests/sec','_Total','iis','win2k8',''),(1290,'Web Service','Post Requests/sec','_Total','iis','win2k8',''),(1291,'Web Service','Total Method Requests/sec','_Total','iis','win2k8',''),(1292,'Web Service Cache','File Cache Hits %','','iis','win2k8','%'),(1293,'Web Service Cache','Kernel: URI Cache Misses','','iis','win2k8',''),(1294,'Web Service Cache','Kernel: URI Cache Hits %','','iis','win2k8','%'),(1295,'Web Service Cache','Kernel: URI Cache Flushes','','iis','win2k8',''),(1296,'MSExchange RpcClientAccess','RPC Operations/sec','','exchange2010','',''),(1297,'MSExchangeAB','Referral RPC Requests Average Latency','','exchange2010','',''),(1298,'MSExchange Control Panel','Requests - Average Response Time','','exchange2010','',''),(1299,'MSExchange Control Panel','Requests - Activations/sec','','exchange2010','',''),(1300,'MSExchange ActiveSync','Requests/sec','','exchange2010','',''),(1301,'MSExchange OWA','Current Unique Users','','exchange2010','',''),(1302,'MSExchange OWA','Requests/sec','','exchange2010','',''),(1303,'MSExchange RpcClientAccess','Connection Count','','exchange2010','',''),(1304,'MSExchange RpcClientAccess','Active User Count','','exchange2010','',''),(1305,'MSExchangeAB','NSPI Connections Current','','exchange2010','',''),(1306,'MSExchangeAB','NSPI RPC Requests/sec','','exchange2010','',''),(1307,'DHCP Server','Packets Expired/sec','','dhcp','win2k8',''),(1308,'DHCP Server','Acks/sec','','dhcp','win2k8',''),(1309,'DHCP Server','Informs/sec','','dhcp','win2k8',''),(1310,'DHCP Server','Nacks/sec','','dhcp','win2k8',''),(1311,'DHCP Server','Declines/sec','','dhcp','win2k8',''),(1312,'DHCP Server','Releases/sec','','dhcp','win2k8',''),(1313,'DHCP Server','Requests/sec ','','dhcp','win2k8',''),(1314,'DHCP Server','Offers/sec','','dhcp','win2k8',''),(1315,'DHCP Server','Duplicates Dropped/sec','','dhcp','win2k8',''),(1316,'DHCP Server','Active Queue Length','','dhcp','win2k8',''),(1317,'DHCP Server','Conflict Check Queue Length','','dhcp','win2k8',''),(1318,'DHCP Server','Discovers/sec','','dhcp','win2k8',''),(1319,'DHCP Server','Packets Received/sec','','dhcp','win2k8',''),(1320,'MSExchangeTransport Dumpster','Dumpster Size','','exchange','win2k8',''),(1321,'MSExchangeTransport Dumpster','Dumpster Inserts/sec','','exchange','win2k8',''),(1322,'MSExchangeTransport Dumpster','Dumpster Item Count','','exchange','win2k8',''),(1323,'MSExchangeTransport Dumpster','Dumpster Deletes/sec','','exchange','win2k8',''),(1324,'MSExchange Database ==> Instances','I/O Log Writes/sec','_Total','exchange','win2k8',''),(1325,'MSExchange Database ==> Instances','I/O Log Reads/sec','_Total','exchange','win2k8',''),(1326,'MSExchange Database ==> Instances','Log Generation Checkpoint Depth','_Total','exchange','win2k8',''),(1327,'MSExchange Database ==> Instances','I/O Database Reads/sec','_Total','exchange','win2k8',''),(1328,'MSExchange Database ==> Instances','I/O Database Writes/sec','_Total','exchange','win2k8',''),(1329,'MSExchange Database ==> Instances','Version buckets allocated','_Total','exchange','win2k8',''),(1330,'MSExchange Database ==> Instances','Log Record Stalls/sec','_Total','exchange','win2k8',''),(1331,'MSExchange Database ==> Instances','Log Threads Waiting','_Total','exchange','win2k8',''),(1332,'MSExchangeTransport SmtpReceive','Messages Received/sec','_Total','exchange','win2k8',''),(1333,'MSExchangeTransport SmtpSend','Messages Sent/sec','_Total','exchange','win2k8',''),(1334,'MSExchangeTransport Queues','Messages Submitted Per Second','_Total','exchange','win2k8',''),(1335,'MSExchangeTransport Queues','Messages Queued for Delivery Per Second','_Total','exchange','win2k8',''),(1336,'MSExchangeTransport Queues','Messages Completed Delivery Per Second','_Total','exchange','win2k8',''),(1337,'MSExchangeTransport Queues','Retry Non-Smtp Delivery Queue Length','_Total','exchange','win2k8',''),(1338,'MSExchangeTransport Queues','Largest Delivery Queue Length','_Total','exchange','win2k8',''),(1339,'MSExchange Resource Booking','Requests Failed','','exchange2010','win2k8',''),(1340,'MSExchange Calendar Attendant','Requests Failed','','exchange2010','win2k8',''),(1341,'MSExchange Store Interface','RPC Requests outstanding','_Total','exchange2010','win2k8',''),(1342,'MSExchange Store Interface','RPC Requests failed (%)','_Total','exchange2010','win2k8','%'),(1343,'MSExchange Mail Submission','Hub Servers In Retry','*','exchange2010','win2k8',''),(1344,'MSExchangeIS','RPC Client Backoff/sec','','exchange2010','win2k8',''),(1345,'MSExchangeIS Mailbox','Messages Delivered/sec','_Total','exchange2010','win2k8',''),(1346,'MSExchangeIS Mailbox','Messages Sent/sec','_Total','exchange2010','win2k8',''),(1347,'MSExchangeIS','User Count','','exchange2010','win2k8',''),(1348,'MSExchange Assistants - Per Database','Mailboxes processed/sec','*','exchange2010','win2k8',''),(1349,'MSExchange Assistants - Per Database','Events Polled/sec','*','exchange2010','win2k8',''),(1350,'MSExchange Database','Database Page Fault Stalls/sec','*','exchange2010','win2k8',''),(1351,'MSExchange Database','Log Record Stalls/sec','*','exchange2010','win2k8',''),(1352,'MSExchange Database','Version buckets allocated','*','exchange2010','win2k8',''),(1353,'MSExchange Database','Database Cache Size (MB)','*','exchange2010','win2k8',''),(1354,'MSExchange Search Indices','Average Document Indexing Time','_Total','exchange2010','win2k8',''),(1355,'MSExchange Assistants - Per Database','Events in queue','*','exchange2010','win2k8',''),(1356,'MSExchange Assistants - Per Database','Average Event Processing Time In Seconds','*','exchange2010','win2k8',''),(1357,'MSExchange Resource Booking','Average Resource Booking Processing Time','','exchange2010','win2k8',''),(1358,'MSExchange Calendar Attendant','Average Calendar Attendant Processing time','','exchange2010','win2k8',''),(1359,'MSExchangeIS','Client: RPCs Failed: Server Too Busy/sec','','exchange2010','win2k8',''),(1360,'MSExchangeIS Client','Directory Access: LDAP Searches/sec','_Total','exchange2010','win2k8',''),(1361,'MSExchangeIS Mailbox','Messages Submitted/sec','_Total','exchange2010','win2k8',''),(1362,'MSExchangeMailSubmission','Temporary Submission Failures/sec','*','exchange2010','win2k8',''),(1363,'MSExchangeUMAvailability','% of Failed Mailbox Connection Attempts Over the Last Hour','','exchange2010um','win2k8','%'),(1364,'MSExchangeUMAvailability','% of Inbound Calls Rejected by the UM Service Over the Last Hour','','exchange2010um','win2k8','%'),(1365,'MSExchangeUMAvailability','% of Inbound Calls Rejected by the UM Worker Process over the Last Hour','','exchange2010um','win2k8','%'),(1366,'MSExchangeUMAvailability','% of Messages Successfully Processed Over the Last Hour   ','','exchange2010um','win2k8','%'),(1367,'MSExchangeUMAvailability','% of Partner Voice Message Transcription Failures Over the Last Hour','','exchange2010um','win2k8','%'),(1368,'MSExchangeUMAvailability','Directory Access Failures','','exchange2010um','win2k8',''),(1369,'MSExchangeUMPerformance','Operations over Six Seconds','','exchange2010um','win2k8',''),(1370,'MSExchangeUMCallAnswer','Calls Disconnected by Callers During UM Audio Hourglass','','exchange2010um','win2k8',''),(1371,'MSExchangeUMGeneral','Average Call Duration','','exchange2010um','win2k8',''),(1372,'MSExchangeUMGeneral','Total Calls','','exchange2010um','win2k8',''),(1373,'MSExchangeUMGeneral','User Response Latency','','exchange2010um','win2k8',''),(1374,'MSExchangeUMCallAnswer','Call Answering Calls','','exchange2010um','win2k8',''),(1375,'MSExchangeUMFax','Percentage of Successful Valid Fax Calls','','exchange2010um','win2k8',''),(1376,'MSExchangeUMAvailability','Calls Disconnected on Irrecoverable Internal Error','','exchange2010um','win2k8',''),(1377,'MSExchangeUMAvailability','Total Inbound Calls Rejected by the UM Service','','exchange2010um','win2k8',''),(1378,'MSExchange Availability Service','Availability Requests (sec)','','exchange2007cas','win2k8',''),(1379,'MSExchange ActiveSync','Average Request Time','','exchange2007cas','win2k8',''),(1380,'MSExchange ActiveSync','Requests/sec','','exchange2007cas','win2k8',''),(1381,'ASP.NET','Requests Current','','exchange2007cas','win2k8',''),(1382,'ASP.NET','Request Wait Time','','exchange2007cas','win2k8',''),(1383,'MSExchange OWA','Average Response Time','','exchange2007cas','win2k8',''),(1384,'MSExchange OWA','Current Unique Users','','exchange2007cas','win2k8',''),(1385,'MSExchange OWA','Requests/sec','','exchange2007cas','win2k8',''),(1386,'MSExchange ADAccess Domain Controllers','LDAP Search Time','*','exchange2007cas','win2k8',''),(1387,'MSExchange ADAccess Processes','LDAP Read Time','*','exchange2007cas','win2k8',''),(1388,'MSExchangeIS Mailbox','Messages Sent/sec','_Total','exchange2007mail','win2k8',''),(1389,'MSExchangeIS Client','Directory Access: LDAP Reads/sec','_Total','exchange2007mail','win2k8',''),(1390,'MSExchangeIS Client','Directory Access: LDAP Searches/sec','_Total','exchange2007mail','win2k8',''),(1391,'MSExchangeIS','User Count','','exchange2007mail','win2k8',''),(1392,'MSExchange Search Indices','Throttling Delay Value','_Total','exchange2007mail','win2k8',''),(1393,'MSExchange Assistants','Average Event Processing Time in Seconds','*','exchange2007mail','win2k8',''),(1394,'MSExchange Resource Booking','Requests Failed','','exchange2007mail','win2k8',''),(1395,'MSExchange Calendar Attendant','Average Calendar Attendant Processing time','','exchange2007mail','win2k8',''),(1396,'MSExchange Calendar Attendant','Requests Failed','','exchange2007mail','win2k8',''),(1397,'MSExchangeIS','RPC Requests','','exchange2007mail','win2k8',''),(1398,'MSExchangeIS','RPC Averaged Latency','','exchange2007mail','win2k8',''),(1399,'MSExchangeIS','RPC Client Backoff/sec','','exchange2007mail','win2k8',''),(1400,'MSExchange Database','Database Page Fault Stalls/sec','*','exchange2007mail','win2k8',''),(1401,'MSExchange Database','Log Record Stalls/sec','*','exchange2007mail','win2k8',''),(1402,'MSExchange Database','Version buckets allocated','*','exchange2007mail','win2k8',''),(1403,'MSExchange Database','Database Cache Size (MB)','*','exchange2007mail','win2k8',''),(1404,'MSExchange Search Indices','Average Document Indexing Time','_Total','exchange2007mail','win2k8',''),(1405,'MSExchange Assistants','Events in queue','*','exchange2007mail','win2k8',''),(1406,'MSExchange Store Interface','RPC Latency average (msec)','_Total','exchange2007mail','win2k8',''),(1407,'MSExchangeMailSubmission','Failed Submissions Per Second','*','exchange2007mail','win2k8',''),(1408,'MSExchangeTransport Dumpster','Dumpster Size','','exchange2007transport','win2k8',''),(1409,'MSExchangeTransport Dumpster','Dumpster Inserts/sec','','exchange2007transport','win2k8',''),(1410,'MSExchangeTransport Dumpster','Dumpster Item Count','','exchange2007transport','win2k8',''),(1411,'MSExchangeTransport Dumpster','Dumpster Deletes/sec','','exchange2007transport','win2k8',''),(1412,'MSExchange Database ==> Instances','I/O Log Writes/sec','_Total','exchange2007transport','win2k8',''),(1413,'MSExchange Database ==> Instances','I/O Log Reads/sec','_Total','exchange2007transport','win2k8',''),(1414,'MSExchange Database ==> Instances','Log Generation Checkpoint Depth','_Total','exchange2007transport','win2k8',''),(1415,'MSExchange Database ==> Instances','I/O Database Reads/sec','_Total','exchange2007transport','win2k8',''),(1416,'MSExchange Database ==> Instances','I/O Database Writes/sec','_Total','exchange2007transport','win2k8',''),(1417,'MSExchange Database ==> Instances','Version buckets allocated','_Total','exchange2007transport','win2k8',''),(1418,'MSExchange Database ==> Instances','Log Record Stalls/sec','_Total','exchange2007transport','win2k8',''),(1419,'MSExchange Database ==> Instances','Log Threads Waiting','_Total','exchange2007transport','win2k8',''),(1420,'MSExchangeTransport SmtpReceive','Messages Received/sec','_Total','exchange2007transport','win2k8',''),(1421,'MSExchangeTransport SmtpSend','Messages Sent/sec','_Total','exchange2007transport','win2k8',''),(1422,'MSExchangeTransport Queues','Messages Submitted Per Second','_Total','exchange2007transport','win2k8',''),(1423,'MSExchangeTransport Queues','Messages Queued for Delivery Per Second','_Total','exchange2007transport','win2k8',''),(1424,'MSExchangeTransport Queues','Messages Completed Delivery Per Second','_Total','exchange2007transport','win2k8',''),(1425,'MSExchangeTransport Queues','Retry Non-Smtp Delivery Queue Length','_Total','exchange2007transport','win2k8',''),(1426,'MSExchangeTransport Queues','Largest Delivery Queue Length','_Total','exchange2007transport','win2k8',''),(1427,'MSExchangeUMAvailability','Unhandled Exceptions/sec','','exchange2007um','win2k8',''),(1428,'MSExchangeUMAvailability','Queued OCS User Event Notifications','','exchange2007um','win2k8',''),(1429,'MSExchangeUMAvailability','Mailbox Server Access Failures','','exchange2007um','win2k8',''),(1430,'MSExchangeUMAvailability','Call Answer Queued Messages','','exchange2007um','win2k8',''),(1431,'MSExchangeUMAvailability','Hub Transport Access Failures','','exchange2007um','win2k8',''),(1432,'MSExchangeUMCallAnswer','Calls Disconnected by Callers During UM Audio Hourglass','','exchange2007um','win2k8',''),(1433,'MSExchangeUMPerformance','Operations over Six Seconds','','exchange2007um','win2k8',''),(1434,'LS:SIP - 01 - Peers','SIP - 017 - Sends Outstanding','_Total','lync_front','',''),(1435,'LS:SIP - 01 - Peers','SIP - 024 - Flow-controlled Connections Dropped','_Total','lync_front','',''),(1436,'LS:SIP - 01 - Peers','SIP - 025 - Average Flow-Control Delay','_Total','lync_front','',''),(1437,'LS:SIP - 01 - Peers','SIP - 028 - Incoming Requests/sec','_Total','lync_front','',''),(1438,'LS:SIP - 02 - Protocol','SIP - 025 - Events In Processing','','lync_front','',''),(1439,'LS:SIP - 04 - Responses','SIP - 053 - Local 500 Responses/sec','','lync_front','',''),(1440,'LS:SIP - 04 - Responses','SIP - 055 - Local 503 Responses/sec','','lync_front','',''),(1441,'LS:SIP - 04 - Responses','SIP - 057 - Local 504 Responses/sec','','lync_front','',''),(1442,'LS:SIP - 07 - Load Management','SIP - 009 - Address space usage','','lync_front','',''),(1443,'LS:SIP - 07 - Load Management','SIP - 010 - Page file usage','','lync_front','',''),(1444,'LS:ImMcu - 00 - IMMcu Conferences','IMMCU - 000 - Active Conferences','','lync_front','',''),(1445,'LS:ImMcu - 00 - IMMcu Conferences','IMMCU - 001 - Connected Users','','lync_front','',''),(1446,'LS:ImMcu - 00 - IMMcu Conferences','IMMCU - 020 - Throttled Sip Connections','','lync_front','',''),(1447,'LS:ImMcu - 02 - MCU Health And Performance','IMMCU - 005 - MCU Health State','','lync_front','',''),(1448,'LS:ImMcu - 02 - MCU Health And Performance','IMMCU - 006 - MCU Draining State','','lync_front','',''),(1449,'LS:USrv - 01 - DBStore','Usrv - 002 - Queue Latency (msec)','','lync_front','',''),(1450,'LS:USrv - 01 - DBStore','Usrv - 004 - Sproc Latency (msec)','','lync_front','',''),(1451,'LS:USrv - 21 - Https Transport','USrv - 003 - Number of failed connection attempts / Sec','','lync_front','',''),(1452,'LS:SIP - 01 - Peers','SIP - 000 - Connections Active','_Total','lync_edge','',''),(1453,'LS:SIP - 01 - Peers','SIP - 001 - TLS Connections Active','_Total','lync_edge','',''),(1454,'LS:SIP - 01 - Peers','SIP - 020 - Average Outgoing Queue Delay','_Total','lync_edge','',''),(1455,'LS:SIP - 01 - Peers','SIP - 028 - Incoming Requests/sec','_Total','lync_edge','',''),(1456,'LS:SIP - 02 - Protocol','SIP - 001 - Incoming Messages/sec','','lync_edge','',''),(1457,'LS:SIP - 07 - Load Management','SIP - 000 - Average Holding Time For Incoming Messages','','lync_edge','',''),(1458,'LS:SIP - 09 - Access Edge Server Messages','SIP - 001 - External Messages/sec With Internally Supported Domain','','lync_edge','',''),(1459,'LS:SIP - 09 - Access Edge Server Messages','SIP - 003 - External Messages/sec Received With Allowed Partner Server Domain','','lync_edge','',''),(1460,'LS:SIP - 09 - Access Edge Server Messages','SIP - 009 - External Messages/sec Received With a Configured Allowed Domain','','lync_edge','',''),(1461,'LS:A/V Edge - 00 - UDP Counters','A/V Edge - 001 - Active Relay Sessions - Authenticated','_Total','lync_edge','',''),(1462,'LS:A/V Edge - 00 - UDP Counters','A/V Edge - 002 - Active Relay Sessions - Allocated Port','_Total','lync_edge','',''),(1463,'LS:A/V Edge - 00 - UDP Counters','A/V Edge - 003 - Active Relay Sessions - Data','_Total','lync_edge','',''),(1464,'LS:A/V Edge - 00 - UDP Counters','A/V Edge - 004 - Allocated Port Pool Count','_Total','lync_edge','',''),(1465,'LS:A/V Edge - 00 - UDP Counters','A/V Edge - 006 - Allocate Requests/sec','_Total','lync_edge','',''),(1466,'LS:A/V Edge - 00 - UDP Counters','A/V Edge - 008 - Authentication Failures/sec','_Total','lync_edge','',''),(1467,'LS:A/V Edge - 00 - UDP Counters','A/V Edge - 009 - Allocate Requests Exceeding Port Limit','_Total','lync_edge','',''),(1468,'LS:A/V Edge - 00 - UDP Counters','A/V Edge - 020 - Packets Received/sec','_Total','lync_edge','',''),(1469,'LS:A/V Edge - 00 - UDP Counters','A/V Edge - 021 - Packets Sent/sec','_Total','lync_edge','',''),(1470,'LS:A/V Edge - 00 - UDP Counters','A/V Edge - 024 - Average Data Packet Latency (milliseconds)','_Total','lync_edge','',''),(1471,'LS:A/V Edge - 00 - UDP Counters','A/V Edge - 029 - Packets Dropped/sec','_Total','lync_edge','',''),(1472,'LS:A/V Edge - 01 - TCP Counters','A/V Edge - 001 - Active Relay Sessions - Authenticated','_Total','lync_edge','',''),(1473,'LS:A/V Edge - 01 - TCP Counters','A/V Edge - 002 - Active Relay Sessions - Allocated Port','_Total','lync_edge','',''),(1474,'LS:A/V Edge - 01 - TCP Counters','A/V Edge - 003 - Active Relay Sessions - Data','_Total','lync_edge','',''),(1475,'LS:A/V Edge - 01 - TCP Counters','A/V Edge - 004 - Allocated Port Pool Count','_Total','lync_edge','',''),(1476,'LS:A/V Edge - 01 - TCP Counters','A/V Edge - 006 - Allocate Requests/sec','_Total','lync_edge','',''),(1477,'LS:A/V Edge - 01 - TCP Counters','A/V Edge - 008 - Authentication Failures/sec','_Total','lync_edge','',''),(1478,'LS:A/V Edge - 01 - TCP Counters','A/V Edge - 009 - Allocate Requests Exceeding Port Limit','_Total','lync_edge','',''),(1479,'LS:A/V Edge - 01 - TCP Counters','A/V Edge - 021 - Packets Received/sec','_Total','lync_edge','',''),(1480,'LS:A/V Edge - 01 - TCP Counters','A/V Edge - 022 - Packets Sent/sec','_Total','lync_edge','',''),(1481,'LS:A/V Edge - 01 - TCP Counters','A/V Edge - 025 - Average Data Packet Latency (milliseconds)','_Total','lync_edge','',''),(1482,'LS:A/V Edge - 01 - TCP Counters','A/V Edge - 030 - Packets Dropped/sec','_Total','lync_edge','',''),(1483,'LS:MediationServer - 00 - Outbound Calls','- 000 - Current','_Total','lync_mediation','',''),(1484,'LS:MediationServer - 00 - Outbound Calls','- 006 - Active media bypass calls','_Total','lync_mediation','',''),(1485,'LS:MediationServer - 01 - Inbound Calls','- 000 - Current','_Total','lync_mediation','',''),(1486,'LS:MediationServer - 01 - Inbound Calls','- 006 - Active media bypass calls','_Total','lync_mediation','',''),(1487,'LS:MediationServer - 02 - Media Relay','- 001 - Media Connectivity Check Failure','','lync_mediation','',''),(1488,'LS:MediationServer - 03 - Health Indices','- 000 - Load Call Failure Index','','lync_mediation','',''),(1489,'LS:MediationServer - 04 - Global Counters','- 000 - Current audio channels with PSM quality reporting','','lync_mediation','',''),(1490,'LS:MediationServer - 04 - Global Counters','- 001 - Total failed calls caused by unexpected interaction from the Proxy','','lync_mediation','',''),(1491,'LS:MediationServer - 05 - Global Per Gateway Counters','- 000 - Total failed calls caused by unexpected interaction from a gateway','_Total','lync_mediation','',''),(1492,'Windows Media Publishing Points','Current Connected Players','*','publishing_point','win2k8r2',''),(1493,'Windows Media Publishing Points','Current File Read Rate (Kbps)','*','publishing_point','win2k8r2',''),(1494,'Windows Media Publishing Points','Current Outgoing Distribution Connections','*','publishing_point','win2k8r2',''),(1495,'Windows Media Publishing Points','Current Player Allocated Bandwidth (Kbps)','*','publishing_point','win2k8r2',''),(1496,'Windows Media Publishing Points','Current Stream Error Rate','*','publishing_point','win2k8r2',''),(1497,'Windows Media Publishing Points','Current Streaming HTTP Players','*','publishing_point','win2k8r2',''),(1498,'Windows Media Publishing Points','Current Streaming Players','*','publishing_point','win2k8r2',''),(1499,'Windows Media Publishing Points','Current Streaming MMS Players','*','publishing_point','win2k8r2',''),(1500,'Windows Media Publishing Points','Current Streaming RTSP Players','*','publishing_point','win2k8r2',''),(1501,'Windows Media Publishing Points','Current Streaming UDP Players','*','publishing_point','win2k8r2',''),(1502,'Windows Media Publishing Points','Peak Connected Players','*','publishing_point','win2k8r2',''),(1503,'Windows Media Publishing Points','Peak Streaming HTTP Players','*','publishing_point','win2k8r2',''),(1504,'Windows Media Publishing Points','Peak Streaming Players','*','publishing_point','win2k8r2',''),(1505,'Windows Media Publishing Points','Peak Streaming RTSP Players','*','publishing_point','win2k8r2',''),(1506,'Windows Media Publishing Points','Peak Streaming UDP Players','*','publishing_point','win2k8r2',''),(1507,'Windows Media Publishing Points','Total Advertisements','*','publishing_point','win2k8r2',''),(1508,'Windows Media Publishing Points','Total Connected Players','*','publishing_point','win2k8r2',''),(1509,'Windows Media Publishing Points','Total Stream Errors','*','publishing_point','win2k8r2',''),(1510,'Windows Media Publishing Points','Total Streaming HTTP Players','*','publishing_point','win2k8r2',''),(1511,'Windows Media Publishing Points','Total Streaming Players','*','publishing_point','win2k8r2',''),(1512,'Windows Media Publishing Points','Total Streaming RTSP Players','*','publishing_point','win2k8r2',''),(1513,'Windows Media Publishing Points','Total Streaming UDP Players','*','publishing_point','win2k8r2',''),(1514,'Windows Media Publishing Points','Current Player Allocated Bandwidth (Kbps)','*','publishing_point','win2k3',''),(1515,'Windows Media Publishing Points','Current Outgoing Distribution Allocated Bandwidth (Kbps)','*','publishing_point','win2k3',''),(1516,'Windows Media Publishing Points','Current Connected Players','*','publishing_point','win2k3',''),(1517,'Windows Media Publishing Points','Current Streaming HTTP Players','*','publishing_point','win2k3',''),(1518,'Windows Media Publishing Points','Current Streaming MMS Players','*','publishing_point','win2k3',''),(1519,'Windows Media Publishing Points','Current Outgoing Distribution Connections','*','publishing_point','win2k3',''),(1520,'Windows Media Publishing Points','Current Streaming RTSP Players','*','publishing_point','win2k3',''),(1521,'Windows Media Publishing Points','Current Streaming Players','*','publishing_point','win2k3',''),(1522,'Windows Media Publishing Points','Current Late Read Rate','*','publishing_point','win2k3',''),(1523,'Windows Media Publishing Points','Current Stream Error Rate','*','publishing_point','win2k3',''),(1524,'Windows Media Publishing Points','Current File Read Rate (Kbps)','*','publishing_point','win2k3',''),(1525,'Windows Media Publishing Points','Peak Player Allocated Bandwidth (Kbps)','*','publishing_point','win2k3',''),(1526,'Windows Media Publishing Points','Peak Outgoing Distribution Allocated Bandwidth (Kbps)','*','publishing_point','win2k3',''),(1527,'Windows Media Publishing Points','Peak Connected Players','*','publishing_point','win2k3',''),(1528,'Windows Media Publishing Points','Peak Outgoing Distribution Connections','*','publishing_point','win2k3',''),(1529,'Windows Media Publishing Points','Peak Streaming Players','*','publishing_point','win2k3',''),(1530,'Windows Media Publishing Points','Total Connected Players','*','publishing_point','win2k3',''),(1531,'Windows Media Publishing Points','Total Outgoing Distribution Connections','*','publishing_point','win2k3',''),(1532,'Windows Media Publishing Points','Total Late Reads','*','publishing_point','win2k3',''),(1533,'Windows Media Publishing Points','Total Stream Denials','*','publishing_point','win2k3',''),(1534,'Windows Media Publishing Points','Total Stream Errors','*','publishing_point','win2k3',''),(1535,'Windows Media Publishing Points','Total Streaming Players','*','publishing_point','win2k3',''),(1536,'Windows Media Publishing Points','Total Stream Terminations','*','publishing_point','win2k3',''),(1537,'Windows Media Publishing Points','Total Advertisements','*','publishing_point','win2k3',''),(1538,'Windows Media Publishing Points','Total File Bytes Read','*','publishing_point','win2k3',''),(1539,'Windows Media Publishing Points','Total Player Bytes Sent','*','publishing_point','win2k3',''),(1540,'Windows Media Publishing Points','Total Outgoing Distribution Bytes Sent','*','publishing_point','win2k3',''),(1541,'Windows Media Publishing Points','Current Connected Players','*','publishing_point','win2k8',''),(1542,'Windows Media Publishing Points','Current File Read Rate (Kbps)','*','publishing_point','win2k8',''),(1543,'Windows Media Publishing Points','Current Outgoing Distribution Connections','*','publishing_point','win2k8',''),(1544,'Windows Media Publishing Points','Current Player Allocated Bandwidth (Kbps)','*','publishing_point','win2k8',''),(1545,'Windows Media Publishing Points','Current Stream Error Rate','*','publishing_point','win2k8',''),(1546,'Windows Media Publishing Points','Current Streaming HTTP Players','*','publishing_point','win2k8',''),(1547,'Windows Media Publishing Points','Current Streaming Players','*','publishing_point','win2k8',''),(1548,'Windows Media Publishing Points','Current Streaming MMS Players','*','publishing_point','win2k8',''),(1549,'Windows Media Publishing Points','Current Streaming RTSP Players','*','publishing_point','win2k8',''),(1550,'Windows Media Publishing Points','Current Streaming UDP Players','*','publishing_point','win2k8',''),(1551,'Windows Media Publishing Points','Peak Connected Players','*','publishing_point','win2k8',''),(1552,'Windows Media Publishing Points','Peak Streaming HTTP Players','*','publishing_point','win2k8',''),(1553,'Windows Media Publishing Points','Peak Streaming Players','*','publishing_point','win2k8',''),(1554,'Windows Media Publishing Points','Peak Streaming RTSP Players','*','publishing_point','win2k8',''),(1555,'Windows Media Publishing Points','Peak Streaming UDP Players','*','publishing_point','win2k8',''),(1556,'Windows Media Publishing Points','Total Advertisements','*','publishing_point','win2k8',''),(1557,'Windows Media Publishing Points','Total Connected Players','*','publishing_point','win2k8',''),(1558,'Windows Media Publishing Points','Total Stream Errors','*','publishing_point','win2k8',''),(1559,'Windows Media Publishing Points','Total Streaming HTTP Players','*','publishing_point','win2k8',''),(1560,'Windows Media Publishing Points','Total Streaming Players','*','publishing_point','win2k8',''),(1561,'Windows Media Publishing Points','Total Streaming RTSP Players','*','publishing_point','win2k8',''),(1562,'Windows Media Publishing Points','Total Streaming UDP Players','*','publishing_point','win2k8',''),(1563,'Windows Media Services','Current Cache Downloads','','streaming2008','win2k8',''),(1564,'Windows Media Services','Current Connected Players','','streaming2008','win2k8',''),(1565,'Windows Media Services','Current Connection Queue Length','','streaming2008','win2k8',''),(1566,'Windows Media Services','Current Connection Rate','','streaming2008','win2k8',''),(1567,'Windows Media Services','Current File Read Rate (Kbps)','','streaming2008','win2k8',''),(1568,'Windows Media Services','Current Incoming Bandwidth (Kbps)','','streaming2008','win2k8',''),(1569,'Windows Media Services','Current Late Read Rate','','streaming2008','win2k8',''),(1570,'Windows Media Services','Current Stream Error Rate','','streaming2008','win2k8',''),(1571,'Windows Media Services','Current Streaming HTTP Players','','streaming2008','win2k8',''),(1572,'Windows Media Services','Current Streaming MMS Players','','streaming2008','win2k8',''),(1573,'Windows Media Services','Current Streaming Players','','streaming2008','win2k8',''),(1574,'Windows Media Services','Current Streaming RTSP Players','','streaming2008','win2k8',''),(1575,'Windows Media Services','Current Streaming UDP Players','','streaming2008','win2k8',''),(1576,'Windows Media Services','Total Connected Players','','streaming2008','win2k8',''),(1577,'Windows Media Services','Total Player Bytes Sent','','streaming2008','win2k8',''),(1578,'Windows Media Services','Total Server Uptime','','streaming2008','win2k8',''),(1579,'Windows Media Services','Total Stream Errors','','streaming2008','win2k8',''),(1580,'Windows Media Services','Total Streaming HTTP Players','','streaming2008','win2k8',''),(1581,'Windows Media Services','Total Streaming Players','','streaming2008','win2k8',''),(1582,'Windows Media Services','Total Streaming RTSP Players','','streaming2008','win2k8',''),(1583,'Windows Media Services','Total Streaming UDP Players','','streaming2008','win2k8',''),(1584,'Windows Media Services','Total Streaming HTTP Players','','streaming2008','win2k8',''),(1585,'Windows Media Services','Total Streaming Players','','streaming2008','win2k8',''),(1586,'Windows Media Services','Total Streaming RTSP Players','','streaming2008','win2k8',''),(1587,'Windows Media Services','Total Streaming UDP Players','','streaming2008','win2k8',''),(1588,'Windows Media Services','Current Cache Downloads','','streaming2008','win2k8r2',''),(1589,'Windows Media Services','Current Connected Players','','streaming2008','win2k8r2',''),(1590,'Windows Media Services','Current Connection Queue Length','','streaming2008','win2k8r2',''),(1591,'Windows Media Services','Current Connection Rate','','streaming2008','win2k8r2',''),(1592,'Windows Media Services','Current File Read Rate (Kbps)','','streaming2008','win2k8r2',''),(1593,'Windows Media Services','Current Incoming Bandwidth (Kbps)','','streaming2008','win2k8r2',''),(1594,'Windows Media Services','Current Late Read Rate','','streaming2008','win2k8r2',''),(1595,'Windows Media Services','Current Stream Error Rate','','streaming2008','win2k8r2',''),(1596,'Windows Media Services','Current Streaming HTTP Players','','streaming2008','win2k8r2',''),(1597,'Windows Media Services','Current Streaming MMS Players','','streaming2008','win2k8r2',''),(1598,'Windows Media Services','Current Streaming Players','','streaming2008','win2k8r2',''),(1599,'Windows Media Services','Current Streaming RTSP Players','','streaming2008','win2k8r2',''),(1600,'Windows Media Services','Current Streaming UDP Players','','streaming2008','win2k8r2',''),(1601,'Windows Media Services','Total Connected Players','','streaming2008','win2k8r2',''),(1602,'Windows Media Services','Total Player Bytes Sent','','streaming2008','win2k8r2',''),(1603,'Windows Media Services','Total Server Uptime','','streaming2008','win2k8r2',''),(1604,'Windows Media Services','Total Stream Errors','','streaming2008','win2k8r2',''),(1605,'Windows Media Services','Total Streaming HTTP Players','','streaming2008','win2k8r2',''),(1606,'Windows Media Services','Total Streaming Players','','streaming2008','win2k8r2',''),(1607,'Windows Media Services','Total Streaming RTSP Players','','streaming2008','win2k8r2',''),(1608,'Windows Media Services','Total Streaming UDP Players','','streaming2008','win2k8r2',''),(1609,'Windows Media Services','Total Streaming HTTP Players','','streaming2008','win2k8r2',''),(1610,'Windows Media Services','Total Streaming Players','','streaming2008','win2k8r2',''),(1611,'Windows Media Services','Total Streaming RTSP Players','','streaming2008','win2k8r2',''),(1612,'Windows Media Services','Total Streaming UDP Players','','streaming2008','win2k8r2',''),(1613,'SMTP Server','Local Queue Length','_Total','xch2003smtp','win2k3',''),(1614,'SMTP Server','Remote Queue Length','_Total','xch2003smtp','win2k3',''),(1615,'SMTP Server','Categorizer Queue Length','_Total','xch2003smtp','win2k3',''),(1616,'MSExchangeIS Mailbox','Receive Queue Size','_Total','xch2003','win2k3',''),(1617,'MSExchangeIS Public','Receive Queue Size','_Total','xch2003','win2k3',''),(1618,'MSExchangeIS','RPC Averaged Latency','','xch2003','win2k3',''),(1619,'MSExchangeIS Mailbox','Send Queue Size','_Total','xch2003','win2k3',''),(1620,'MSExchangeIS Public','Send Queue Size','_Total','xch2003','win2k3',''),(1621,'MSExchangeAL','Address Lists Queue Length','_Total','xch2003','win2k3',''),(1622,'FTP Service','Bytes Received/sec','_Total','ftp','win2k8',''),(1623,'FTP Service','Bytes Sent/sec','_Total','ftp','win2k8',''),(1624,'FTP Service','Current Anonymous Users','_Total','ftp','win2k8',''),(1625,'FTP Service','Current Connections','_Total','ftp','win2k8',''),(1626,'FTP Service','Current NonAnonymous Users','_Total','ftp','win2k8',''),(1627,'FTP Service','Total Connection Attempts (all instances)','_Total','ftp','win2k8',''),(1628,'FTP Service','Total Files Received','_Total','ftp','win2k8',''),(1629,'FTP Service','Total Files Sent','_Total','ftp','win2k8',''),(1630,'FTP Service','Total Files Transferred','_Total','ftp','win2k8',''),(1631,'WINS Server','Failed Queries/sec','','wins','',''),(1632,'WINS Server','Failed Releases/sec','','wins','',''),(1633,'WINS Server','Group Conflicts/sec','','wins','',''),(1634,'WINS Server','Group Registrations/sec','','wins','',''),(1635,'WINS Server','Group Renewals/sec','','wins','',''),(1636,'WINS Server','Queries/sec','','wins','',''),(1637,'WINS Server','Releases/sec','','wins','',''),(1638,'WINS Server','Successful Queries/sec','','wins','',''),(1639,'WINS Server','Successful Releases/sec','','wins','',''),(1640,'WINS Server','Total Number of Conflicts/sec','','wins','',''),(1641,'WINS Server','Total Number of Renewals/sec','','wins','',''),(1642,'WINS Server','Unique Conflicts/sec','','wins','',''),(1643,'WINS Server','Unique Registrations/sec','','wins','',''),(1644,'WINS Server','Unique Renewals/sec','','wins','',''),(1645,'Microsoft FTP Service','Bytes Received/sec','_Total','ftp','win2012',''),(1646,'Microsoft FTP Service','Bytes Sent/sec','_Total','ftp','win2012',''),(1647,'Microsoft FTP Service','Current Anonymous Users','_Total','ftp','win2012',''),(1648,'Microsoft FTP Service','Current Connections','_Total','ftp','win2012',''),(1649,'Microsoft FTP Service','Current NonAnonymous Users','_Total','ftp','win2012',''),(1650,'Microsoft FTP Service','Total Connection Attempts','_Total','ftp','win2012',''),(1651,'Microsoft FTP Service','Total Files Received','_Total','ftp','win2012',''),(1652,'Microsoft FTP Service','Total Files Sent','_Total','ftp','win2012',''),(1653,'Microsoft FTP Service','Total Files Transferred','_Total','ftp','win2012',''),(1654,'Microsoft FTP Service','Bytes Received/sec','_Total','ftp','win2k8r2',''),(1655,'Microsoft FTP Service','Bytes Sent/sec','_Total','ftp','win2k8r2',''),(1656,'Microsoft FTP Service','Current Anonymous Users','_Total','ftp','win2k8r2',''),(1657,'Microsoft FTP Service','Current Connections','_Total','ftp','win2k8r2',''),(1658,'Microsoft FTP Service','Current NonAnonymous Users','_Total','ftp','win2k8r2',''),(1659,'Microsoft FTP Service','Total Connection Attempts','_Total','ftp','win2k8r2',''),(1660,'Microsoft FTP Service','Total Files Received','_Total','ftp','win2k8r2',''),(1661,'Microsoft FTP Service','Total Files Sent','_Total','ftp','win2k8r2',''),(1662,'Microsoft FTP Service','Total Files Transferred','_Total','ftp','win2k8r2',''),(1663,'FTP Service','Bytes Received/sec','_Total','ftp','win2k3',''),(1664,'FTP Service','Bytes Sent/sec','_Total','ftp','win2k3',''),(1665,'FTP Service','Current Anonymous Users','_Total','ftp','win2k3',''),(1666,'FTP Service','Current Connections','_Total','ftp','win2k3',''),(1667,'FTP Service','Current NonAnonymous Users','_Total','ftp','win2k3',''),(1668,'FTP Service','Total Connection Attempts (all instances)','_Total','ftp','win2k3',''),(1669,'FTP Service','Total Files Received','_Total','ftp','win2k3',''),(1670,'FTP Service','Total Files Sent','_Total','ftp','win2k3',''),(1671,'FTP Service','Total Files Transferred','_Total','ftp','win2k3',''),(1672,'Forefront TMG Firewall Packet Engine','Active Connections','','tmg','win2k8',''),(1673,'Forefront TMG Firewall Packet Engine','Bytes/sec','','tmg','win2k8',''),(1674,'Forefront TMG Firewall Packet Engine','Dropped Packets/sec','','tmg','win2k8',''),(1675,'Forefront TMG Firewall Packet Engine','Packets/sec','','tmg','win2k8',''),(1676,'Forefront TMG Firewall Packet Engine','Connections/sec','','tmg','win2k8',''),(1677,'Forefront TMG H.323 Filter','Active H.323 Calls','','tmg','win2k8',''),(1678,'Forefront TMG SOCKS Filter','Pending DNS Resolutions','','tmg','win2k8',''),(1679,'Forefront TMG Cache','Disk Failure Rate (failures/sec)','','tmg','win2k8',''),(1680,'Forefront TMG Cache','Memory Usage Ratio Percent (%)','','tmg','win2k8','%'),(1681,'Forefront TMG Cache','URL Commit Rate (URL/sec)','','tmg','win2k8',''),(1682,'Forefront TMG Firewall Service','DNS Cache Hits %','','tmg','win2k8','%'),(1683,'Forefront TMG Firewall Service','Active Sessions','','tmg','win2k8',''),(1684,'Forefront TMG Firewall Service','Active TCP Connections','','tmg','win2k8',''),(1685,'Forefront TMG Firewall Service','Active UDP Connections','','tmg','win2k8',''),(1686,'Forefront TMG Firewall Service','Available Worker Threads','','tmg','win2k8',''),(1687,'Forefront TMG Firewall Service','Worker Threads','','tmg','win2k8',''),(1688,'Forefront TMG SOCKS Filter','Active Sessions','','tmg','win2k8',''),(1689,'Forefront TMG Web Proxy','Active Web Sessions','','tmg','win2k8',''),(1690,'Forefront TMG Web Proxy','Average Milliseconds/request','','tmg','win2k8',''),(1691,'Forefront TMG Web Proxy','Cache Hit Ratio (%)','','tmg','win2k8','%'),(1692,'Forefront TMG Web Proxy','Connect Errors','','tmg','win2k8',''),(1693,'Forefront TMG Web Proxy','Failing Requests/sec','','tmg','win2k8',''),(1694,'Forefront TMG Web Proxy','Requests/sec','','tmg','win2k8',''),(1695,'Forefront TMG Web Proxy','Thread Pool Active Sessions','','tmg','win2k8',''),(1696,'Forefront TMG Web Proxy','Memory Pool for HTTP Requests (%)','','tmg','win2k8','%'),(1697,'Forefront TMG Web Proxy','Memory Pool for SSL Requests (%)','','tmg','win2k8','%'),(1698,'Forefront TMG Web Proxy','Compression - Current Compression Ratio','','tmg','win2k8',''),(1699,'Forefront TMG Web Proxy','Compression - Responses Compressed: Accumulated Ratio','','tmg','win2k8',''),(1700,'Forefront TMG Firewall Packet Engine','Active Connections','','tmg','win2k8r2',''),(1701,'Forefront TMG Firewall Packet Engine','Bytes/sec','','tmg','win2k8r2',''),(1702,'Forefront TMG Firewall Packet Engine','Dropped Packets/sec','','tmg','win2k8r2',''),(1703,'Forefront TMG Firewall Packet Engine','Packets/sec','','tmg','win2k8r2',''),(1704,'Forefront TMG Firewall Packet Engine','Connections/sec','','tmg','win2k8r2',''),(1705,'Forefront TMG H.323 Filter','Active H.323 Calls','','tmg','win2k8r2',''),(1706,'Forefront TMG SOCKS Filter','Pending DNS Resolutions','','tmg','win2k8r2',''),(1707,'Forefront TMG Cache','Disk Failure Rate (failures/sec)','','tmg','win2k8r2',''),(1708,'Forefront TMG Cache','Memory Usage Ratio Percent (%)','','tmg','win2k8r2','%'),(1709,'Forefront TMG Cache','URL Commit Rate (URL/sec)','','tmg','win2k8r2',''),(1710,'Forefront TMG Firewall Service','DNS Cache Hits %','','tmg','win2k8r2','%'),(1711,'Forefront TMG Firewall Service','Active Sessions','','tmg','win2k8r2',''),(1712,'Forefront TMG Firewall Service','Active TCP Connections','','tmg','win2k8r2',''),(1713,'Forefront TMG Firewall Service','Active UDP Connections','','tmg','win2k8r2',''),(1714,'Forefront TMG Firewall Service','Available Worker Threads','','tmg','win2k8r2',''),(1715,'Forefront TMG Firewall Service','Worker Threads','','tmg','win2k8r2',''),(1716,'Forefront TMG SOCKS Filter','Active Sessions','','tmg','win2k8r2',''),(1717,'Forefront TMG Web Proxy','Active Web Sessions','','tmg','win2k8r2',''),(1718,'Forefront TMG Web Proxy','Average Milliseconds/request','','tmg','win2k8r2',''),(1719,'Forefront TMG Web Proxy','Cache Hit Ratio (%)','','tmg','win2k8r2','%'),(1720,'Forefront TMG Web Proxy','Connect Errors','','tmg','win2k8r2',''),(1721,'Forefront TMG Web Proxy','Failing Requests/sec','','tmg','win2k8r2',''),(1722,'Forefront TMG Web Proxy','Requests/sec','','tmg','win2k8r2',''),(1723,'Forefront TMG Web Proxy','Thread Pool Active Sessions','','tmg','win2k8r2',''),(1724,'Forefront TMG Web Proxy','Memory Pool for HTTP Requests (%)','','tmg','win2k8r2','%'),(1725,'Forefront TMG Web Proxy','Memory Pool for SSL Requests (%)','','tmg','win2k8r2','%'),(1726,'Forefront TMG Web Proxy','Compression - Current Compression Ratio','','tmg','win2k8r2',''),(1727,'Forefront TMG Web Proxy','Compression - Responses Compressed: Accumulated Ratio','','tmg','win2k8r2',''),(1728,'Print Queue','Not Ready Errors','_Total','printer','',''),(1729,'Print Queue','Out of Paper Errors','_Total','printer','',''),(1730,'Print Queue','Jobs Spooling','_Total','printer','',''),(1731,'Print Queue','Job Errors','_Total','printer','',''),(1732,'Print Queue','Jobs','_Total','printer','',''),(1733,'Print Queue','Total Jobs Printed','_Total','printer','',''),(1734,'Process','Thread Count','spoolsv','printer','','');
/*!40000 ALTER TABLE `rules` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-07-27 10:12:06
