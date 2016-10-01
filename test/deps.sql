-- Note: pgTap is loaded by setup.sql

-- Assume that if this works in a specific schema it'll work anywhere
\set install_schema range_tools_install
CREATE SCHEMA :install_schema;
CREATE EXTENSION range_type_functions WITH SCHEMA :install_schema;
