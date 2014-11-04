-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Tue Nov  4 16:38:22 2014
-- 

;
BEGIN TRANSACTION;
--
-- Table: servers
--
CREATE TABLE servers (
  server_id INTEGER PRIMARY KEY NOT NULL,
  server_name VARCHAR(255) NOT NULL,
  server_network VARCHAR(255) NOT NULL
);
CREATE UNIQUE INDEX servers_server_name ON servers (server_name);
--
-- Table: leankits
--
CREATE TABLE leankits (
  leankit_id INTEGER PRIMARY KEY NOT NULL,
  server_id INT NOT NULL,
  channel_name VARCHAR(255) NOT NULL,
  default_board_id INT NOT NULL,
  default_board_name VARCHAR(255) NOT NULL,
  FOREIGN KEY (server_id) REFERENCES servers(server_id)
);
CREATE INDEX leankits_idx_server_id ON leankits (server_id);
--
-- Table: plugins
--
CREATE TABLE plugins (
  plugin_id INTEGER PRIMARY KEY NOT NULL,
  server_id INT NOT NULL,
  plugin_name VARCHAR(255) NOT NULL,
  FOREIGN KEY (server_id) REFERENCES servers(server_id)
);
CREATE INDEX plugins_idx_server_id ON plugins (server_id);
CREATE UNIQUE INDEX plugins_plugin_name ON plugins (plugin_name);
COMMIT;
