/bin/rm -f ../WebContent/js/common-*.js
#/bin/rm -f ../WebContent/js/commonPc-*.js
/bin/rm -f ../WebContent/js/upload-*.js
/bin/rm -f ../WebContent/js/update-*.js

/bin/cp ./js/common-99.js ../WebContent/js/
#/bin/cp ./js/commonPc-04.js ../WebContent/js/
/bin/cp ./js/upload-47.js ../WebContent/js/
/bin/cp ./js/update-20.js ../WebContent/js/

CLOSURE_COMPILER_JAR="./closure-compiler-v20201006.jar"
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/common-99.js --js_output_file ../WebContent/js/common-99.js
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/commonPc-04.js --js_output_file ../WebContent/js/commonPc-04.js
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/upload-47.js --js_output_file ../WebContent/js/upload-47.js
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/update-20.js --js_output_file ../WebContent/js/update-20.js

##for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done
