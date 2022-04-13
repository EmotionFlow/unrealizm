ENV_FILE=.env
if [ ! -f ${ENV_FILE} ]; then
 echo ${ENV_FILE} is not found.
 exit
fi

source ${ENV_FILE}

/bin/rm -f ${WEB_CONTENT}js/common-*.js
#/bin/rm -f ${WEB_CONTENT}js/commonPc-*.js
/bin/rm -f ${WEB_CONTENT}js/upload-*.js
/bin/rm -f ${WEB_CONTENT}js/update-*.js

/bin/cp ./js/common-106.js ${WEB_CONTENT}js/
#/bin/cp ./js/commonPc-04.js ${WEB_CONTENT}js/
/bin/cp ./js/upload-48.js ${WEB_CONTENT}js/
/bin/cp ./js/update-20.js ${WEB_CONTENT}js/

CLOSURE_COMPILER_JAR="./closure-compiler-v20201006.jar"
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/common-106.js --js_output_file ${WEB_CONTENT}js/common-106.js
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/commonPc-04.js --js_output_file ${WEB_CONTENT}js/commonPc-04.js
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/upload-48.js --js_output_file ${WEB_CONTENT}js/upload-48.js
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/update-20.js --js_output_file ${WEB_CONTENT}js/update-20.js

##for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/${file} --js_output_file ${WEB_CONTENT}js/${file}
#done
