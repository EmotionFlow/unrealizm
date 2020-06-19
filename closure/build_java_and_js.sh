#!/bin/bash

SOURCE_PATH="../src"
DEST_PATH="../build"
DEPLOY_PATH="../WebContent/WEB-INF/classes"
CLASSES_WEB_INF="../WebContent/WEB-INF/lib/*"
CLASSES_TOMCAT="/usr/local/tomcat/lib/*"
JAVA_FILE_ROOT="../src/jp/pipa/poipiku"
JAVA_FILE_DIRS=("/controller" "/servlet" "/util" "/payment")

export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home"

java -version

rm -rf $DEST_PATH
mkdir $DEST_PATH

echo /
javac -sourcepath $SOURCE_PATH -d $DEST_PATH -cp $CLASSES_WEB_INF:$CLASSES_TOMCAT:$DEST_PATH $JAVA_FILE_ROOT/*.java

for dir in "${JAVA_FILE_DIRS[@]}"; do
    echo $dir
    javac -sourcepath $SOURCE_PATH -d $DEST_PATH -cp $CLASSES_WEB_INF:$CLASSES_TOMCAT:$DEST_PATH $JAVA_FILE_ROOT$dir/*.java
done

echo build ok

rsync -a $DEST_PATH/ $DEPLOY_PATH/

echo rsync ok

./closure.sh

echo closure ok
