#!/bin/bash
set -eu

ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
 echo ${ENV_FILE} is not found.
 exit
fi

source ${ENV_FILE}

/bin/rm -rf ${WEB_CONTENT}WEB-INF/classes/jp
