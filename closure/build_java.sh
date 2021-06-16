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
SOURCE_PATH="../src"
DEPLOY_PATH="../WebContent/WEB-INF/classes"
CLASSES_WEB_INF="../WebContent/WEB-INF/lib/*"
JAVA_FILE_ROOT="../src/jp/pipa/poipiku"
JAVA_FILE_DIRS=("/controller" "/servlet" "/util" "/settlement/epsilon" "/settlement" "/notify")

java -version

echo /
${JAVAC} -Xlint:unchecked -sourcepath $SOURCE_PATH -d $DEPLOY_PATH -cp $CLASSES_WEB_INF:$CLASSES_TOMCAT:$DEST_PATH $JAVA_FILE_ROOT/*.java

for dir in "${JAVA_FILE_DIRS[@]}"; do
		echo $dir
		${JAVAC} -Xlint:unchecked -sourcepath $SOURCE_PATH -d $DEPLOY_PATH -cp $CLASSES_WEB_INF:$CLASSES_TOMCAT:$DEPLOY_PATH $JAVA_FILE_ROOT$dir/*.java
done

echo build ok
