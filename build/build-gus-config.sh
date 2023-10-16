#!/bin/bash

set -e

GUS_CONFIG_FILE=$GUS_HOME/config/gus.config

function replaceDBI() {
  sed -i "s#<dbiDsn>.*#$1#" $GUS_CONFIG_FILE
}

function replaceVendor() {
  sed -i "s#<dbVendor>.*#$1#" $GUS_CONFIG_FILE
}

function replaceJDBC () {
  sed -i "s#<jdbcDsn>.*#$1#" $GUS_CONFIG_FILE
}

function replaceDBUser() {
  sed -i "s#<dbLogin>.*#$1#" $GUS_CONFIG_FILE
}

function replaceDBPassword() {
  sed -i "s#<dbPassword>.*#$1#" $GUS_CONFIG_FILE
}

function replaceUnixUser() {
  sed -i "s#<unixLogin>.*#$1#" $GUS_CONFIG_FILE
}

function replaceProjectName() {
  sed -i "s#<projectName>.*#$1#" $GUS_CONFIG_FILE
}

function configureGUS() {
  cp $GUS_HOME/config/gus.config.sample $GUS_CONFIG_FILE
  replaceDBI "dbi:Pg:dbname=$TEMPLATE_DB_NAME"
  replaceVendor "Postgres"
  replaceJDBC "jdbc:postgresql://localhost/$TEMPLATE_DB_NAME"
  replaceDBUser "someone"
  replaceDBPassword "password"
  replaceUnixUser "root"
  replaceProjectName "PlasmoDB"
}

configureGUS

