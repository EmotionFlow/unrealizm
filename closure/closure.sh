java -jar ./closure-compiler-v20180805.jar --js ./js/common-20.js --js_output_file ../WebContent/js/common-20.js
java -jar ./closure-compiler-v20180805.jar --js ./js/upload-06.js --js_output_file ../WebContent/js/upload-06.js

#for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ./closure-compiler-v20180805.jar --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done

