#!/bin/sh

set -e

mkdir -p $GUS_HOME/bin $GUS_HOME/lib $GUS_HOME/config $PROJECT_HOME

# Get ojdbc8
mkdir -p $GUS_HOME/lib/java/db_driver
cd $GUS_HOME/lib/java/db_driver
wget https://download.oracle.com/otn-pub/otn_software/jdbc/233/ojdbc8.jar

# CLONE INSTALL
cd $PROJECT_HOME
git clone https://github.com/VEuPathDB/install.git
cd $PROJECT_HOME/install
git reset --hard $INSTALL_COMMIT_HASH

# CLONE CBIL
cd $PROJECT_HOME
git clone https://github.com/VEuPathDB/CBIL.git
cd $PROJECT_HOME/CBIL
git reset --hard $CBIL_COMMIT_HASH

# CLONE GUS
cd $PROJECT_HOME
git clone https://github.com/VEuPathDB/GusAppFramework.git GUS
cd $PROJECT_HOME/GUS
git reset --hard $GUS_COMMIT_HASH

# CLONE GUS SCHEMA
cd $PROJECT_HOME
git clone https://github.com/VEuPathDB/GusSchema.git
cd $PROJECT_HOME/GusSchema
git reset --hard $GUS_SCHEMA_COMMIT_HASH

# SETUP APIDB SCHEMA
cd $PROJECT_HOME
git clone https://github.com/VEuPathDB/ApidbSchema.git
cd $PROJECT_HOME/ApidbSchema
git reset --hard $APIDB_SCHEMA_COMMIT_HASH

# SETUP INSTALL UTILS
cd $PROJECT_HOME
git clone https://github.com/VEuPathDB/SchemaInstallUtils.git
cd SchemaInstallUtils
git reset --hard $LIB_INSTALL_COMMIT_HASH

