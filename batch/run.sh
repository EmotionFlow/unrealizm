#!/bin/bash
set -e

ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
  echo ${ENV_FILE} is not found.
  exit
fi

# shellcheck disable=SC1090
source ${ENV_FILE}

BATCH_CLASSES="./classes"

APP_JAR_PATH="../WebContent/WEB-INF/lib/"
POSTGRES_JAR="${APP_JAR_PATH}postgresql-42.2.14.jre7.jar"
VELOCITY_JAR="${APP_JAR_PATH}velocity-engine-core-2.3.jar:${APP_JAR_PATH}slf4j-api-1.7.9.jar"
COMMONS_JAR="${APP_JAR_PATH}commons-lang3-3.7.jar:${APP_JAR_PATH}commons-io-2.4.jar"
HTTP_CLI_JAR="${APP_JAR_PATH}kotlin-stdlib-1.5.0.jar:${APP_JAR_PATH}okio-2.10.0.jar:${APP_JAR_PATH}okhttp-4.9.1.jar"
JACKSON_JAR="${APP_JAR_PATH}jackson-all-1.9.7.jar"

APP_JAR="${POSTGRES_JAR}:${VELOCITY_JAR}:${COMMONS_JAR}:${HTTP_CLI_JAR}:${JACKSON_JAR}"

WEB_CONENT_CLASSES="../WebContent/WEB-INF/classes/"

java -DdbPass=${DB_PASS} -DdbPort=${DB_PORT} -cp ${APP_JAR}:${CLASSES_TOMCAT}:${WEB_CONENT_CLASSES}:${BATCH_CLASSES} jp.pipa.poipiku.batch.$1

#RUN_CMD="java -cp ${APP_JAR}:${CLASSES_TOMCAT}:${WEB_CONENT_CLASSES}:${BATCH_CLASSES} $1"

#bash -c "${RUN_CMD} ${RUN_CMD_OPT}"

exit
