#!/bin/bash

SOURCE_PATH="../src"
DEST_PATH="../build"
DEPLOY_PATH="../WebContent/WEB-INF/classes"
CLASSES_WEB_INF="../WebContent/WEB-INF/lib/*"
CLASSES_TOMCAT="/opt/java/tomcat/apache-tomcat-7.0.107/lib/*"
JAVA_FILE_ROOT="../src/jp/pipa/poipiku"
JAVA_FILE_DIRS=("/controller" "/servlet" "/util" "/settlement/epsilon" "/settlement")

export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu8.50.0.1013-ca-jdk8.0.275-macos_aarch64"

java -version

rm -rf $DEST_PATH
mkdir $DEST_PATH

echo /
javac -Xlint:unchecked -sourcepath $SOURCE_PATH -d $DEST_PATH -cp $CLASSES_WEB_INF:$CLASSES_TOMCAT:$DEST_PATH $JAVA_FILE_ROOT/*.java

for dir in "${JAVA_FILE_DIRS[@]}"; do
		echo $dir
		javac -Xlint:unchecked -sourcepath $SOURCE_PATH -d $DEST_PATH -cp $CLASSES_WEB_INF:$CLASSES_TOMCAT:$DEST_PATH $JAVA_FILE_ROOT$dir/*.java
done

echo build ok

rsync -a $DEST_PATH/ $DEPLOY_PATH/

echo rsync ok

./closure.sh

echo closure ok
