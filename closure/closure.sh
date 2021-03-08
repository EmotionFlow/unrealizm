/bin/rm ../WebContent/js/common-*.js
#/bin/rm ../WebContent/js/commonPc-*.js
/bin/rm ../WebContent/js/upload-*.js
/bin/rm ../WebContent/js/update-*.js

/bin/cp ./js/common-47.js ../WebContent/js/
#/bin/cp ./js/commonPc-03.js ../WebContent/js/
/bin/cp ./js/upload-33.js ../WebContent/js/
/bin/cp ./js/update-09.js ../WebContent/js/

CLOSURE_COMPILER_JAR="./closure-compiler-v20201006.jar"
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/common-47.js --js_output_file ../WebContent/js/common-47.js
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/commonPc-03.js --js_output_file ../WebContent/js/commonPc-03.js
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/upload-33.js --js_output_file ../WebContent/js/upload-33.js
java -jar ${CLOSURE_COMPILER_JAR} --js ./js/update-09.js --js_output_file ../WebContent/js/update-09.js

##for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ${CLOSURE_COMPILER_JAR} --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done
