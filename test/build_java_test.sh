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

CLASSES_WEB_INF="../WebContent/WEB-INF/lib/*"
JAVA_FILE_ROOT="./jp/pipa/poipiku"
#JAVA_FILE_DIRS=("/controller" "/servlet" "/util" "/settlement/epsilon" "/settlement")

TEST_TARGET="../WebContent/WEB-INF/classes/"
JUNIT5_JAR="../test/lib/junit-platform-console-standalone-1.7.1.jar"

CLASS_PATH=$CLASSES_WEB_INF:$CLASSES_TOMCAT:$JUNIT5_JAR:$TEST_TARGET

java -version

echo /
${JAVAC} -Xlint:unchecked -sourcepath $SOURCE_PATH -d $TEST_CLASSES -cp $CLASS_PATH $JAVA_FILE_ROOT/*.java

#for dir in "${JAVA_FILE_DIRS[@]}"; do
#		echo $dir
#		${JAVAC} -Xlint:unchecked -sourcepath $SOURCE_PATH -d $TEST_CLASSES -cp $CLASS_PATH $JAVA_FILE_ROOT$dir/*.java
#done

echo build ok

java -jar $JUNIT5_JAR \
     -cp $CLASSES_WEB_INF:$CLASSES_TOMCAT:$TEST_TARGET:$TEST_CLASSES \
     --select-package jp.pipa.poipiku \
     --include-classname='.*Test$'

exit
