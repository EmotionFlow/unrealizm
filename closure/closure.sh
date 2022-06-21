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

/bin/cp ./js/common-111.js ${WEB_CONTENT}js/
#/bin/cp ./js/commonPc-04.js ${WEB_CONTENT}js/
/bin/cp ./js/upload-50.js ${WEB_CONTENT}js/
/bin/cp ./js/update-23.js ${WEB_CONTENT}js/

CLOSURE_COMPILER_JAR="./closure-compiler-v20201006.jar"
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/common-111.js --js_output_file ${WEB_CONTENT}js/common-111.js
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/commonPc-04.js --js_output_file ${WEB_CONTENT}js/commonPc-04.js
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/upload-50.js --js_output_file ${WEB_CONTENT}js/upload-50.js
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/update-23.js --js_output_file ${WEB_CONTENT}js/update-23.js

##for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/${file} --js_output_file ${WEB_CONTENT}js/${file}
#done
