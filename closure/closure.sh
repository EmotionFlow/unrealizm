java -jar ./closure-compiler-v20181125.jar --js ./js/common-40.js --js_output_file ../WebContent/js/common-40.js
#java -jar ./closure-compiler-v20181125.jar --js ./js/commonPc-03.js --js_output_file ../WebContent/js/commonPc-03.js
java -jar ./closure-compiler-v20181125.jar --js ./js/upload-23.js --js_output_file ../WebContent/js/upload-23.js
java -jar ./closure-compiler-v20181125.jar --js ./js/update-03.js --js_output_file ../WebContent/js/update-03.js

#for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ./closure-compiler-v20181125.jar --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done
