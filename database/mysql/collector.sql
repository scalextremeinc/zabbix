CREATE TABLE `collectors` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `path` varchar(1024) NOT NULL,
  `parameters` text,
  PRIMARY KEY (id)
) ENGINE=TokuDB DEFAULT CHARSET=utf8;

ALTER TABLE items ADD collectorid bigint unsigned;
