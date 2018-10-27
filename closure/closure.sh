#java -jar ./closure-compiler-v20180805.jar --js ./js/common-21.js --js_output_file ../WebContent/js/common-21.js
java -jar ./closure-compiler-v20180805.jar --js ./js/upload-07.js --js_output_file ../WebContent/js/upload-07.js

#for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ./closure-compiler-v20180805.jar --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done

