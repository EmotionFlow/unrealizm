#!/bin/bash
set -e

ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
  echo ${ENV_FILE} is not found.
  exit
fi

# shellcheck disable=SC1090
source ${ENV_FILE}

JAVAC=${JAVA_HOME}/bin/javac
SOURCE_PATH="."
TEST_CLASSES="./classes"

APP_JAR_PATH="../WebContent/WEB-INF/lib/"
POSTGRES_JAR="${APP_JAR_PATH}postgresql-42.2.14.jre7.jar"
VELOCITY_JAR="${APP_JAR_PATH}velocity-engine-core-2.3.jar:${APP_JAR_PATH}slf4j-api-1.7.9.jar"
COMMONS_JAR="${APP_JAR_PATH}commons-lang3-3.7.jar:${APP_JAR_PATH}commons-io-2.4.jar"
HTTP_CLI_JAR="${APP_JAR_PATH}kotlin-stdlib-1.5.0.jar:${APP_JAR_PATH}okio-2.10.0.jar:${APP_JAR_PATH}okhttp-4.9.1.jar"
JACKSON_JAR="${APP_JAR_PATH}jackson-all-1.9.7.jar"

APP_JAR="${POSTGRES_JAR}:${VELOCITY_JAR}:${COMMONS_JAR}:${HTTP_CLI_JAR}:${JACKSON_JAR}"

JAVA_FILE_ROOT="./jp/pipa/poipiku"
#JAVA_FILE_DIRS=("/controller" "/servlet" "/util" "/settlement/epsilon" "/settlement")

TEST_TARGET="../WebContent/WEB-INF/classes/"
JUNIT5_JAR="../test/lib/junit-platform-console-standalone-1.7.1.jar"

CLASS_PATH="${APP_JAR}:${CLASSES_TOMCAT}:${JUNIT5_JAR}:${TEST_TARGET}"

rm -rf ${TEST_CLASSES}/jp

java -version

echo ${CLASS_PATH}
echo /
${JAVAC} -Xlint:unchecked -Xlint:deprecation \
  -sourcepath ${SOURCE_PATH} -d ${TEST_CLASSES} -cp ${CLASS_PATH} ${JAVA_FILE_ROOT}/*.java

#for dir in "${JAVA_FILE_DIRS[@]}"; do
#		echo $dir
#		${JAVAC} -Xlint:unchecked -sourcepath $SOURCE_PATH -d $TEST_CLASSES -cp $CLASS_PATH $JAVA_FILE_ROOT$dir/*.java
#done

echo build ok

TEST_CMD="java -jar ${JUNIT5_JAR} -cp ${APP_JAR}:${CLASSES_TOMCAT}:${TEST_TARGET}:${TEST_CLASSES} --select-package jp.pipa.poipiku"
TEST_CMD_OPT=--include-classname='.*Test$'

if [ $# -eq 1 ]; then
  TEST_CMD_OPT="--include-classname='.*"
  TEST_CMD_OPT+=$1
  TEST_CMD_OPT+="Test$'"
fi

echo TEST_CMD_OPT is ${TEST_CMD_OPT}

bash -c "${TEST_CMD} ${TEST_CMD_OPT}"

exit
