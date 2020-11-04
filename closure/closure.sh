java -jar ./closure-compiler-v20201006.jar --js ./js/common-41.js --js_output_file ../WebContent/js/common-41.js
#java -jar ./closure-compiler-v20201006.jar --js ./js/commonPc-03.js --js_output_file ../WebContent/js/commonPc-03.js
java -jar ./closure-compiler-v20201006.jar --js ./js/upload-27.js --js_output_file ../WebContent/js/upload-27.js
java -jar ./closure-compiler-v20201006.jar --js ./js/update-05.js --js_output_file ../WebContent/js/update-05.js

#for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ./closure-compiler-v20201006.jar --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done
