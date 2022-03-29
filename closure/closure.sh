/bin/rm -f ../WebContent/js/common-*.js
#/bin/rm -f ../WebContent/js/commonPc-*.js
/bin/rm -f ../WebContent/js/upload-*.js
/bin/rm -f ../WebContent/js/update-*.js

/bin/cp ./js/common-104.js ../WebContent/js/
#/bin/cp ./js/commonPc-04.js ../WebContent/js/
/bin/cp ./js/upload-48.js ../WebContent/js/
/bin/cp ./js/update-20.js ../WebContent/js/

CLOSURE_COMPILER_JAR="./closure-compiler-v20201006.jar"
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/common-104.js --js_output_file ../WebContent/js/common-104.js
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/commonPc-04.js --js_output_file ../WebContent/js/commonPc-04.js
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/upload-48.js --js_output_file ../WebContent/js/upload-48.js
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/update-20.js --js_output_file ../WebContent/js/update-20.js

##for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done
