#!/bin/bash

set -e

GUS_CONFIG_FILE=$GUS_HOME/config/gus.config

function confReplace() {
  sed -i "s#$1.*#$2#" $GUS_CONFIG_FILE
}

cp $GUS_HOME/config/gus.config.sample $GUS_CONFIG_FILE

confReplace "<dbiDsn>" "dbi:Pg:dbname=$TEMPLATE_DB_NAME"
confReplace "<dbVendor>" "Postgres"
confReplace "<jdbcDsn>" "jdbc:postgresql://localhost/$TEMPLATE_DB_NAME"
confReplace "<dbLogin>" "someone"
confReplace "<dbPassword>" "password"
confReplace "<unixLogin>" "root"
confReplace "<projectName>" "PlasmoDB"
