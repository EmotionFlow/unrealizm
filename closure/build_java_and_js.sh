#!/bin/bash
set -eu

ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
 echo ${ENV_FILE} is not found.
 exit
fi

./closure.sh &
./build_java.sh
