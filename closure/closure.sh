/bin/cp ./js/common-43.js ../WebContent/js/
##/bin/cp ./js/commonPc-03.js ../WebContent/js/
/bin/cp ./js/upload-27.js ../WebContent/js/
/bin/cp ./js/update-05.js ../WebContent/js/


java -jar ./closure-compiler-v20201006.jar --js ./js/common-43.js --js_output_file ../WebContent/js/common-43.js
##java -jar ./closure-compiler-v20201006.jar --js ./js/commonPc-03.js --js_output_file ../WebContent/js/commonPc-03.js
java -jar ./closure-compiler-v20201006.jar --js ./js/upload-27.js --js_output_file ../WebContent/js/upload-27.js
java -jar ./closure-compiler-v20201006.jar --js ./js/update-05.js --js_output_file ../WebContent/js/update-05.js


##for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ./closure-compiler-v20201006.jar --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done
