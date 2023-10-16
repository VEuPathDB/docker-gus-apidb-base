#!/bin/sh

su postgres <<EOSU
initdb
pg_ctl start
EOSU

# Make tablespace dir for indx tablespace???
mkdir -p /var/lib/postgres/data/indx
chown postgres:postgres /var/lib/postgres/data/indx

psql -U postgres <<EOSQL
CREATE USER ${TEMPLATE_DB_USER} WITH LOGIN PASSWORD '${TEMPLATE_DB_PASS}';

CREATE DATABASE ${TEMPLATE_DB_NAME} WITH OWNER ${TEMPLATE_DB_USER};

-- support gus_r
CREATE ROLE gus_r;
GRANT gus_r TO ${TEMPLATE_DB_USER} WITH INHERIT TRUE;

-- support gus_w
CREATE ROLE gus_w;
GRANT gus_w TO ${TEMPLATE_DB_USER} WITH INHERIT TRUE;

-- apparently we need an "indx" tablespace
CREATE TABLESPACE indx OWNER ${TEMPLATE_DB_USER} LOCATION '/var/lib/postgres/data/indx';
EOSQL

cd $GUS_HOME/bin

build GUS install -append -installDBSchemaSkipRoles

DB_PLATFORM=Postgres \
DB_USER=$TEMPLATE_DB_USER \
DB_PASS=$TEMPLATE_DB_PASS \
./installApidbSchema --dbName $TEMPLATE_DB_NAME --dbHost localhost --create

su postgres -c 'pg_ctl stop'
