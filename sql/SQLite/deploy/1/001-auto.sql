-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Mon Nov  3 14:00:58 2014
-- 

;
BEGIN TRANSACTION;
--
-- Table: servers
--
CREATE TABLE servers (
  server_id INTEGER PRIMARY KEY NOT NULL,
  server_name VARCHAR(255) NOT NULL
);
CREATE UNIQUE INDEX servers_server_name ON servers (server_name);
--
-- Table: channels
--
CREATE TABLE channels (
  channel_id INTEGER PRIMARY KEY NOT NULL,
  server_id INT NOT NULL,
  channel_name VARCHAR(255) NOT NULL,
  FOREIGN KEY (server_id) REFERENCES servers(server_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX channels_idx_server_id ON channels (server_id);
CREATE UNIQUE INDEX channels_channel_name ON channels (channel_name);
--
-- Table: plugins
--
CREATE TABLE plugins (
  plugin_id INTEGER PRIMARY KEY NOT NULL,
  channel_id INT NOT NULL,
  plugin_name VARCHAR(255) NOT NULL,
  FOREIGN KEY (channel_id) REFERENCES channels(channel_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX plugins_idx_channel_id ON plugins (channel_id);
CREATE UNIQUE INDEX plugins_plugin_name ON plugins (plugin_name);
COMMIT;