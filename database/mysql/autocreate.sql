CREATE TABLE `autocreate` (
  `app` varchar(255) NOT NULL,
  `enabled` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`app`)
) ENGINE=TokuDB DEFAULT CHARSET=utf8
