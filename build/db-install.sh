#!/bin/bash

set -e

PATH=$PROJECT_HOME/install/bin:$GUS_HOME/bin:$PATH

stopInstance() {
  su postgres -c '/usr/lib/postgresql/15/bin/pg_ctl stop'
}

stopInstanceAndExit() {
  stopInstance
  exit 1;
}

# Trap any ERR signal and run the stopInstance function
trap 'stopInstanceAndExit' ERR

echo "Initializing Postgres"
su postgres <<EOSU
/usr/lib/postgresql/15/bin/initdb
/usr/lib/postgresql/15/bin/pg_ctl start
EOSU

echo "Creating 'indx' tablespace directory"
mkdir -p /var/lib/postgres/data/indx
chown postgres:postgres /var/lib/postgres/data/indx

echo "Creating Postgres Database"
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

echo "Running GUS install"
build GUS install -append -installDBSchemaSkipRoles

echo "Running installApidbSchema"
DB_PLATFORM=Postgres \
  DB_USER=$TEMPLATE_DB_USER \
  DB_PASS=$TEMPLATE_DB_PASS \
  installApidbSchema --dbName $TEMPLATE_DB_NAME --dbHost localhost --create


echo "Building GUS and ApiDB Model Objects"

touch $PROJECT_HOME/GusSchema/Definition/config/gus_schema.xml
bld GUS

stopInstance
