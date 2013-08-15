alter table history add column hour int(11) not null default 0;
CREATE INDEX history_2 ON history (hour);
