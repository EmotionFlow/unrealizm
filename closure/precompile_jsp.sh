#!/bin/bash
set -eu

ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
 echo ${ENV_FILE} is not found.
 exit
fi

# shellcheck disable=SC1090
source ${ENV_FILE}

echo java:$JAVA_HOME
echo tomcat:$TOMCAT_HOME

ant -version

pushd jsp-precompile
rm -rf jspc
rm -rf compile
mkdir jspc
mkdir compile
TOMCAT_HOME=${TOMCAT_HOME} ant
popd
