#!/bin/bash

set -e

PATH=$PROJECT_HOME/install/bin:$PATH

# # build install
# cd $PROJECT_HOME/install
# cp -r bin/* $GUS_HOME/bin
# cp -r lib/* $GUS_HOME/lib
# cp -r config/* $GUS_HOME/config

echo "build CBIL"
bld CBIL
# # build GusSchema
# cd $PROJECT_HOME/GusSchema
# cp -r Definition/bin/* $GUS_HOME/bin
# cp -r Definition/config/* $GUS_HOME/config


echo "build ApidbSchema"
bld ApidbSchema
# cd $PROJECT_HOME/ApidbSchema
# mkdir -p $GUS_HOME/lib/sql/apidbschema
# cp -r Main/bin/* $GUS_HOME/bin
# cp -r Main/lib/sql/* $GUS_HOME/lib/sql/

# # install SchemaInstallUtils
# cd $PROJECT_HOME/SchemaInstallUtils
# mkdir -p $GUS_HOME/lib/perl/SchemaInstallUtils/Main/
# cp Main/Utils.pm $GUS_HOME/lib/perl/SchemaInstallUtils/Main/

echo "build GUS plugins"
bld GUS/PluginMgr
bld GUS/Supported

echo "build Api plugins"
cd $PROJECT_HOME/ApiCommonData
mkdir -p $GUS_HOME/lib/perl/ApiCommonData/Load/Plugin
cp Load/plugin/perl/*.pm $GUS_HOME/lib/perl/ApiCommonData/Load/Plugin/
cp -r Load/lib/perl/* $GUS_HOME/lib/perl/ApiCommonData/Load/
