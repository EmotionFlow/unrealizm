#java -jar ./closure-compiler-v20181125.jar --js ./js/common-33.js --js_output_file ../WebContent/js/common-33.js
#java -jar ./closure-compiler-v20181125.jar --js ./js/commonPc-03.js --js_output_file ../WebContent/js/commonPc-03.js
java -jar ./closure-compiler-v20181125.jar --js ./js/upload-18.js --js_output_file ../WebContent/js/upload-18.js

#for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ./closure-compiler-v20181125.jar --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done

