#!/bin/zsh

SOURCE_PATH="../src"
DEST_PATH="../build"
DEPLOY_PATH="../WebContent/WEB-INF/classes"
CLASSES_WEB_INF="../WebContent/WEB-INF/lib/*"
CLASSES_TOMCAT="/usr/local/tomcat/lib/*"
JAVA_FILE_ROOT="../src/jp/pipa/poipiku"
JAVA_FILE_DIRS=("" "/controller" "/servlet" "/util")

rm -rf $DEST_PATH
mkdir $DEST_PATH

for dir in $JAVA_FILE_DIRS; do
    javac -sourcepath $SOURCE_PATH -d $DEST_PATH -cp $CLASSES_WEB_INF:$CLASSES_TOMCAT:$DEST_PATH $JAVA_FILE_ROOT$dir/*.java
done

echo build ok

rsync -av $DEST_PATH/ $DEPLOY_PATH/

echo rsync ok

./closure.sh

echo closure ok
