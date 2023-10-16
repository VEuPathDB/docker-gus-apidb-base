#!/bin/sh

su postgres <<EOSU
initdb
pg_ctl start
EOSU

# Make tablespace dir for indx tablespace???
mkdir -p /var/lib/postgres/data/indx
chown postgres:postgres /var/lib/postgres/data/indx

psql -U postgres <<EOSQL
CREATE USER someone WITH LOGIN PASSWORD 'password';

CREATE DATABASE template WITH OWNER someone;

-- support gus_r
CREATE ROLE gus_r;
GRANT gus_r TO someone WITH INHERIT TRUE;

-- support gus_w
CREATE ROLE gus_w;
GRANT gus_w TO someone WITH INHERIT TRUE;

-- apparently we need an "indx" tablespace
CREATE TABLESPACE indx OWNER someone LOCATION '/var/lib/postgres/data/indx';
EOSQL

cd $GUS_HOME/bin

build GUS install -append -installDBSchemaSkipRoles

DB_PLATFORM=Postgres \
DB_USER=someone \
DB_PASS="password" \
./installApidbSchema --dbName template --dbHost localhost --create

su postgres -c 'pg_ctl stop'
