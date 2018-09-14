java -jar ./closure-compiler-v20180805.jar --js ./js/common-12.js --js_output_file ../WebContent/js/common-12.js

#for file in $( ls ./js | grep .js$ ); do
#echo "${file}"
#java -jar ./closure-compiler-v20180805.jar --js ./js/${file} --js_output_file ../WebContent/js/${file}
#done

