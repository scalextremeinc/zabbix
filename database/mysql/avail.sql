CREATE TABLE `avail` (
  `itemid` bigint unsigned NOT NULL,
  `type` int(11) NOT NULL DEFAULT 0,
  `enabled` int(11) NOT NULL DEFAULT 0,
  `parameters` text,
  PRIMARY KEY (`itemid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8

