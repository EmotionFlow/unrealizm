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
JAVA_FILE_ROOT="./src/jp/pipa/poipiku"

java -version

echo ${CLASS_PATH}
echo /
${JAVAC} -Xlint:unchecked -Xlint:deprecation \
  -sourcepath ${SOURCE_PATH} -d ${BATCH_CLASSES} -cp ${CLASS_PATH} ${JAVA_FILE_ROOT}/batch/*.java

echo build ok

exit
