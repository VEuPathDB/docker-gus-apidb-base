#!/bin/bash

set -e

echo "build CBIL"
bld CBIL

echo "build ApidbSchema"
bld ApidbSchema

echo "build GUS plugins"
bld GUS/PluginMgr
bld GUS/Supported
