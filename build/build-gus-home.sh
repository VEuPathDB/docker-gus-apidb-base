#!/bin/bash

set -e

# install install
cd $PROJECT_HOME/install
cp -r bin/* $GUS_HOME/bin
cp -r lib/* $GUS_HOME/lib
cp -r config/* $GUS_HOME/config

# install CBIL
cd $PROJECT_HOME/CBIL
mkdir -p $GUS_HOME/lib/perl/CBIL/Util
cp -r Util/lib/perl/* $GUS_HOME/lib/perl/CBIL/Util
cp -r Util/bin $GUS_HOME/bin

# install GusSchema
cd $PROJECT_HOME/GusSchema
cp -r Definition/bin/* $GUS_HOME/bin
cp -r Definition/config/* $GUS_HOME/config

# install ApidbSchema
cd $PROJECT_HOME/ApidbSchema
mkdir -p $GUS_HOME/lib/sql/apidbschema
cp -r Main/bin/* $GUS_HOME/bin
cp -r Main/lib/sql/* $GUS_HOME/lib/sql/apidbschema

# install SchemaInstallUtils
cd $PROJECT_HOME/SchemaInstallUtils
mkdir -p $GUS_HOME/lib/perl/SchemaInstallUtils/Main/
cp Main/Utils.pm $GUS_HOME/lib/perl/SchemaInstallUtils/Main/

