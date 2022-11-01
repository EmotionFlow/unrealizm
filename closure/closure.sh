#!/usr/bin/env bash
set -e

ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
 echo ${ENV_FILE} is not found.
 exit
fi

# shellcheck disable=SC1090
source ${ENV_FILE}

if [ -z "$WEB_CONTENT" ]; then
  echo WEB_CONTENT is empty.
  exit
fi

/bin/rm -f ${WEB_CONTENT}js/common-*.js
#/bin/rm -f ${WEB_CONTENT}js/commonPc-*.js
/bin/rm -f ${WEB_CONTENT}js/upload-*.js
/bin/rm -f ${WEB_CONTENT}js/update-*.js

JS_FILES=("common-125.js" "upload-52.js" "upload-51-8.js" "update-25.js" "update-25-4.js")


if [ $APP_ENVIRONMENT == "development" ]; then
  for jsfile in "${JS_FILES[@]}"; do
    /bin/cp ./js/${jsfile} ${WEB_CONTENT}js/
  done
else
  CLOSURE_COMPILER_JAR="./closure-compiler-v20201006.jar"
  for jsfile in "${JS_FILES[@]}"; do
    echo $jsfile
    java -jar ${CLOSURE_COMPILER_JAR} --js ./js/${jsfile} --js_output_file ${WEB_CONTENT}js/${jsfile}
  done
fi



##for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/${file} --js_output_file ${WEB_CONTENT}js/${file}
#done
