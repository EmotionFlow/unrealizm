/bin/rm -f ../WebContent/js/common-*.js
#/bin/rm -f ../WebContent/js/commonPc-*.js
/bin/rm -f ../WebContent/js/upload-*.js
/bin/rm -f ../WebContent/js/update-*.js

/bin/cp ./js/common-50.js ../WebContent/js/
#/bin/cp ./js/commonPc-03.js ../WebContent/js/
/bin/cp ./js/upload-39.js ../WebContent/js/
/bin/cp ./js/update-13.js ../WebContent/js/

CLOSURE_COMPILER_JAR="./closure-compiler-v20201006.jar"
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/common-50.js --js_output_file ../WebContent/js/common-50.js
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/commonPc-03.js --js_output_file ../WebContent/js/commonPc-03.js
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/upload-39.js --js_output_file ../WebContent/js/upload-39.js
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/update-13.js --js_output_file ../WebContent/js/update-13.js

##for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done
