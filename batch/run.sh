#!/bin/bash
set -e

ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
  echo ${ENV_FILE} is not found.
  exit
fi

# shellcheck disable=SC1090
source ${ENV_FILE}

java -DAPP_ENVIRONMENT=${APP_ENVIRONMENT} \
-DdbHost=${DB_HOST} -DdbPass=${DB_PASS} -DdbPort=${DB_PORT} \
-DreplicaDbHost=${REPLICA_DB_HOST} -DreplicaDbPass=${REPLICA_DB_PASS} -DreplicaDbPort=${REPLICA_DB_PORT} \
-cp ${APP_JAR}:${CLASSES_TOMCAT}:${WEB_CONTENT_CLASSES}:${BATCH_CLASSES} \
jp.pipa.poipiku.batch.$1 $2

#RUN_CMD="java -cp ${APP_JAR}:${CLASSES_TOMCAT}:${WEB_CONENT_CLASSES}:${BATCH_CLASSES} $1"

#bash -c "${RUN_CMD} ${RUN_CMD_OPT}"

exit
