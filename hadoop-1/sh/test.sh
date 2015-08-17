#!/bin/bash

echo $0
echo $1

para1="prefix"$1

echo $para1

thisDir=`dirname "$0"`
echo "$thisDir"
pwd
thisDir=`cd "$thisDir" > /dev/null; pwd`
echo "$thisDir"
pwd
